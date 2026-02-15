#!/bin/bash
# Files utility functions for shell toolbox

in_path() {
  # Given a command and the PATH, tries to find the command. Returns 0 if
  #   found and executable; 1 if not. Note that this temporarily modifies
  #   the IFS (internal field separator) but restores it upon completion.
  local cmd=$1
  local ourpath=$2
  local result=1
  local old_ifs=$IFS
  IFS=":"

  for directory in $ourpath; do
    [ -x "$directory/$cmd" ] && result=0 # If we're here, we found the command.
  done

  IFS=$old_ifs
  return $result
}

check_for_cmd_in_path() {
  # Checks if a command exists in PATH or is an executable file.
  # Args: $1=command
  # Returns: 0 if found/executable, 1 if not executable, 2 if not in PATH
  local cmd=$1

  [ -n "$cmd" ] && {
    if [ "${cmd:0:1}" = "/" ]; then
      [ ! -x "$cmd" ] && return 1
    elif ! in_path "$cmd" "$PATH"; then
      return 2
    fi
  }
}

echo_n() {
  # Prints arguments without a trailing newline.
  # Args: $@=strings to print
  if check_for_cmd_in_path printf; then
    printf "%s" "$*"
  else
    echo "$*" | tr -d '\n'
  fi
}

get_file_with_fzf() {
  # Interactively selects a file or directory using fzf.
  # Args: $1=path to file or directory
  # Returns: path to selected file/directory, exits on error
  local file="$1"
  [ ! -f "$file" ] &&
    [ ! -d "$file" ] &&
    error_exit "$file is not a proper file or directory." 2

  FD=$(find "$file" -mindepth 1 -maxdepth 1 ! -name '.*')

  local directory
  directory=$(
    echo "$FD" |
      sed -n '1p' |
      xargs -I {} dirname {}
  )

  file=$(
    echo "$FD" |
      xargs -I {} basename {} 2>/dev/null |
      fzf --bind=tab:up --bind=btab:down --bind=ctrl-g:first
  ) || exit 1

  [ -d "$directory/$file" ] &&
    get_file_with_fzf "$directory/$file/" ||
    echo "$directory/$file"
}

get_env_file_from_path() {
  # Recursively searches up the directory tree for .env files.
  # Args: $1=starting directory path
  # Returns: path to .env file found, exits if none found or reaches HOME
  local envdir="$1"
  [ -z "$envdir" ] && error_exit "You must specify env directory."
  local envfile
  envfile=$(find "$envdir" -name ".env*")
  local parentdir
  parentdir=$(dirname "$envdir")

  [ "$envdir" == "$HOME" ] && error_exit "You don't have any env file in your path."
  [ -z "$envfile" ] && get_env_file_from_path "$parentdir" || echo "$envfile"
}
