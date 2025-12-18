#!/bin/bash
# Core utility functions for shell toolbox

# Error Handling
echo_error() {
  # Prints an error message to stderr
  # shellcheck disable=SC2154
  echo "${redf}Error:${reset} $1" >&2
}
error_exit() {
  # Prints an error message to stderr and exits with a specified code (default 1).
  echo_error "$1"
  exit "${2:-1}"
}

return_error() {
  # Prints an error message to stderr and returns with a specified code 1.
  echo_error "$1"
  return 1
}

error_usage() {
  # Prints an error message to stderr, attempts to call usage(), and exits if usage fails.
  echo_error "$1"
  usage || {
    error_exit "Function usage don't fund it" 1
  }
}

# Logging
## Logging Configuration
export __TOOLBOX_LOG_PREFIX="" # Prefix for log messages
export __TOOLBOX_LOG_OUTPUT="" # File path for log output (empty means stdout)
export __TOOLBOX_LOG_LEVEL=0   # Minimum log level to output (0-9, higher = more verbose)

## Logging Functions
toolbox_log() {
  # Logs messages at a specified level, outputting to file and/or stdout based on config.
  # Args: $1=level (int), $2+=message parts
  [[ "${__TOOLBOX_LOG_LEVEL}" =~ ^[0-9]+$ ]] || {
    builtin echo "TOOLBOX ERROR : __TOOLBOX_LOG_LEVEL should be an integer, found ${__TOOLBOX_LOG_LEVEL} instead"
    exit 2
  }

  [[ "$1" =~ ^[0-9]+$ ]] || {
    builtin echo "TOOLBOX ERROR : toolbox_log() first parameter has to be an integer, used $1 instead"
    exit 2
  }

  [ "$__TOOLBOX_LOG_LEVEL" -lt "$1" ] && return 1
  shift

  [ -n "$__TOOLBOX_LOG_OUTPUT" ] && {
    printf "[%s - %-20s] " "$(date)" "$__TOOLBOX_LOG_PREFIX"
    printf "%s " "$@"
    printf "\n"
  } >>"$__TOOLBOX_LOG_OUTPUT"

  builtin echo "$@"
  return 0
}

redirect_to_log() {
  # Sets logging configuration variables; returns success if output file is set.
  # Args: $1=prefix (opt), $2=output_file (opt), $3=level (opt)
  export __TOOLBOX_LOG_PREFIX="${1:-$__TOOLBOX_LOG_PREFIX}"
  export __TOOLBOX_LOG_OUTPUT="${2:-$__TOOLBOX_LOG_OUTPUT}"
  export __TOOLBOX_LOG_LEVEL="${3:-$__TOOLBOX_LOG_LEVEL}"

  [ -n "$__TOOLBOX_LOG_OUTPUT" ] && return 0 || return 1
}

set_log_category() {
  # Sets the log prefix/category while keeping other logging config unchanged.
  # Args: $1=category/prefix
  redirect_to_log "$1" "$__TOOLBOX_LOG_OUTPUT"
}

# File System Utilities
sanitize_filename() {
  # Sanitizes a filename by replacing unsafe characters with underscores.
  # Args: $1=filename
  # Returns: cleaned filename safe for file paths
  local filename="$1"
  echo "${filename//[^a-zA-Z0-9._-]/_}"
}

ensure_output_dir() {
  # Ensures a directory exists, creating it if necessary.
  # Args: $1=output_dir
  # Exits with error if creation fails
  local output_dir="$1"
  [[ ! -d "$output_dir" ]] && {
    mkdir -p "$output_dir" || error_exit "Could not create output directory: $output_dir" 2
  }
  return 0
}

# String Utilities
normalize() {
  # Normalizes a string: first char uppercase, next two lowercase (e.g., for names).
  # Args: $1=string
  # Returns: normalized string
  firstPart="$(/bin/echo -n "$1" | cut -c1 | tr '[:lower:]' '[:upper:]')"
  secondPart="$(echo "$1" | cut -c2-3 | tr '[:upper:]' '[:lower:]')"
  echo "$firstPart$secondPart"
}

make_unique() {
  # Removes duplicate lines from input arguments, preserving order.
  # Args: $@=list of items
  # Returns: unique items
  echo "$@" | awk '!a[$0]++'
}

# Logical Utilities
not() {
  # Inverts a binary value (0 becomes 1, 1 becomes 0).
  # Args: $1=value (0 or 1)
  # Returns: inverted value, exits on invalid input
  [ "$1" -eq 0 ] && echo 1 && return 0
  [ "$1" -eq 1 ] && echo 0 && return 1
  error_exit "not() function can only be used with 0 or 1 as parameter" 2
}

is_default() {
  # Checks if a variable is set to its default value (based on _is_default flag).
  # Args: $1=var_name (without _is_default suffix)
  # Returns: 0 if default, 1 otherwise
  [ "$(eval "echo \$${1}_is_default")" -eq 1 ] && return 0 || return 1
}

is_empty() {
  # Checks if a string is empty.
  # Args: $1=string
  # Returns: 0 (echo 1) if empty, 1 (echo 0) if not
  [ -z "$1" ] && echo 1 && return 0
  echo 0 && return 1
}

or_condition() {
  # Returns 1 if any argument is non-zero, 0 if all are zero.
  # Args: $@=list of return codes/values
  # Returns: 1 (true) if any true, 0 (false) if all false
  while [ -n "$1" ]; do
    [ "$1" -ne 0 ] && echo 1 && return 0
    shift
  done
  echo 0 && return 1
}

# Environment Inspection
print_env() {
  # Prints toolbox environment variables and sourced files at a given detail level.
  # Args: $1=level (1=basic, >1=include sourced file contents)
  level=${1:-1}

  [[ $level -gt 1 ]] && {
    for src in "${toolbox_SOURCED[@]}"; do
      echo "Sourced from $src :"
      cat "$src"
    done
  }

  for idx in "${toolbox_POSITIONAL_IDXES[@]}"; do
    varname=$(positional_print_varname "$idx")
    value=$(eval "echo \${$varname}")
    echo "$varname='$value'"
  done

  for idx in "${toolbox_IDXES[@]}"; do
    echo "$(option_print_varname "$idx")"="$(option_print_value "$idx")"
  done
}
