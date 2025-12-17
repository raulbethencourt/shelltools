#!/bin/bash

# validAlphaNum--Ensures that input consists only of alphabetical and whitespace
#   and numeric characters

# Validate arg: returns 0 if all upper+lower+digits; 1 otherwise
validAlphaNum() {
  # Remove all unacceptable chars and whitespace.
  validchars=${1//[^[:alnum:]]/}

  [ "$validchars" = "$1" ] && return 0 || return 1
}

[ "${BASH_SOURCE[*]}" = "$0" ] && {
  /usr/bin/echo -n "Enter input: "
  read -r input

  # Input validation
  ! validAlphaNum "$input" && {
    echo "Please enter only letters and numbers." >&2 && exit 1
  } || echo "Input is valid."

  exit 0
}
