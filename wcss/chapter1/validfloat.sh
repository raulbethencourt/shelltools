#!/bin/bash

# validfloat -- Tests whether a number is a valid floating-point value,
#   Note that this script cannot accept scientific (1.304e5) notations.
#
# To test whether an entered value es a valid floating-point number,
#   we need to split the value into two parts: the integer portion
#   and the fractional portion. We test the first part see whether
#   it's a valid integer, and then we test whether the second part is a
#   valid >=0 integer. So -30.5 evaluates as valid, but -30.-8 doesn't.
#
# To include another shell script as part of this one, use the "." source
#   notation. Easy enough.

. validint.sh

validfloat() {
  fvalue="$1"

  # Check whether the input number has a decimal point.
  # shellcheck disable=SC2001,SC2015
  [ -n "$(echo "$fvalue" | sed 's/[^.]//g')" ] && {
    decimalPart=$(echo "$fvalue" | cut -d. -f1)
    fractionalPart=$(echo "$fvalue" | cut -d. -f2)

    # Start by testing the decimal part, which is everything
    #   to the left of the decimal point.
    [ -n "$decimalPart" ] && {
      ! validint "$decimalPart" "" "" && return 1
    }

    # Now let's test the fractional value.
    #
    # To start, you can't have a negative sign after the decimal point
    #   like 33.-1, so let's test for the '-' sign in the decimal.
    [ -n "$(echo "$fractionalPart" | sed "s/[^-]//g")" ] && {
      echo "Invalid floating-point number: '-' not allowed after decimal point." >&2 && return 1
    }
    [ -n "$fractionalPart" ] && {
      validint "$fractionalPart" "0" "" && return 0 || return 1
    } || {
      echo "The number is empty after the dot." >&2 && return 1
    }
  } || {
    echo "The input is not a floating-point number." >&2 && return 1
  }
}

[ "${BASH_SOURCE[*]}" = "$0" ] && {
  validfloat "$1" "$2" "$3" && echo "Input is valid float within your contraints." || exit 1
}
