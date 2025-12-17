#!/bin/bash

error_exit() {
  echo "Error: $1" >&2
  exit "${2:-1}"
}

error_usage() {
  echo "Error: $1" >&2
  usage || {
    error_exit "Function usage don't fund it" 1
  }
}

toolbox_log() {

  [[ "${__TOOLBOX_LOG_LEVEL}" =~ ^[0-9]+$ ]] || {
    builtin echo "TOOLBOX ERROR : __TOOLBOX_LOG_LEVEL should be an integer, found ${__TOOLBOX_LOG_LEVEL} instead"
    exit 242
  }

  [[ "$1" =~ ^[0-9]+$ ]] || {
    builtin echo "TOOLBOX ERROR : toolbox_log() first parameter has to be an integer, used $1 instead"
    exit 242
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
