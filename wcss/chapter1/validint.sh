#!/bin/bash

# validint -- Validates integer input, allowing negative integers too

validint() {
  # Validate first field and test that value against min value $2 and/or
  #   max value $3 if they are supplied. If the value isn't within range
  #   or it's not composed of just digits, fail.

  number="$1"
  min="$2"
  max="$3"

  # set -x

  [ -z "$number" ] && echo "You didn't enter anything. Please enter a number" >&2 && return 1

  # Is the first character a '-' sign?
  [ "$(echo "$number" | cut -c1)" = "-" ] && testvalue=$(echo "$number" | cut -d- -f2) || testvalue="$number"

  # Create a version of the number that has no digits for testing.
  nodigits=$(echo "$testvalue" | sed ' s/[[:digit:]]//g')

  [ -n "$nodigits" ] && echo "Invalid number format! Only digits, no commas, spaces, etc." >&2 && return 1

  [ -n "$min" ] && {
    # Is the input less than the minimum value ?
    [ "$number" -lt "$min" ] && echo "Your value is too small: smallest acceptable value is $min." >&2 && return 1
  }

  [ -n "$max" ] && {
    # Is the input greater than the maximun value ?
    [ "$number" -gt "$max" ] && echo "Your value is too big: largest acceptable value is $max." >&2 && return 1
  }

  return 0
}

[ "${BASH_SOURCE[*]}" = "$0" ] && {
  validint "$1" "$2" "$3" && echo "Input is valid integer within your contraints." && exit 0
}
