#!/bin/bash
# Validation utility functions for shell toolbox

# Integer Validation
validint() {
   # Description: Validates an integer, checking for digits only, and optional min/max range.
   # Args: $1=number (string), $2=min (opt, integer), $3=max (opt, integer)
   # Returns: 0 on success, exits with error on failure

  number="$1"
  min="$2"
  max="$3"

  [ -z "$number" ] && return_error "You didn't enter anything. Please enter a number"

  # Is the first character a '-' sign?
  [ "$(echo "$number" | cut -c1)" = "-" ] &&
    testvalue=$(echo "$number" | cut -d- -f2) ||
    testvalue="$number"

  # Create a version of the number that has no digits for testing.
  nodigits=$(echo "$testvalue" | sed ' s/[[:digit:]]//g')

  [ -n "$nodigits" ] &&
    return_error "Invalid number format! Only digits, no commas, spaces, etc."

  # Is the input less than the minimum value ?
  [ -n "$min" ] &&
    [ "$number" -lt "$min" ] &&
    return_error "Your value is too small: smallest acceptable value is $min."

  # Is the input greater than the maximun value ?
  [ -n "$max" ] &&
    [ "$number" -gt "$max" ] &&
    return_error "Your value is too big: largest acceptable value is $max."

  return 0
}

# Float Validation
validfloat() {
  # Description: Validates a floating-point number with optional decimal part.
  # Args: $1=float_value (string)
  # Returns: 0 on success, 1 on failure (calls error_exit internally)
  fvalue="$1"

  # Check whether the input number has a decimal point.
  # shellcheck disable=SC2001,SC2015
  [ -n "$(echo "$fvalue" | sed 's/[^.]//g')" ] && {
    decimalPart=$(echo "$fvalue" | cut -d. -f1)
    fractionalPart=$(echo "$fvalue" | cut -d. -f2)

    # Start by testing the decimal part, which is everything
    #   to the left of the decimal point.
    [ -n "$decimalPart" ] && ! validint "$decimalPart" "" "" && return 1

    # Now let's test the fractional value.
    #
    # To start, you can't have a negative sign after the decimal point
    #   like 33.-1, so let's test for the '-' sign in the decimal.
    [ -n "$(echo "$fractionalPart" | sed "s/[^-]//g")" ] &&
      return_error "Invalid floating-point number: '-' not allowed after decimal point."
    [ -n "$fractionalPart" ] && {
      validint "$fractionalPart" "0" "" && return 0 || return 1
    } || return_error "The number is empty after the dot."
  } || return_error "The input is not a floating-point number."
}

# Date/Time Validation
exceedDaysInMonth() {
  # Description: Checks if a day number exceeds the maximum days in the given month.
  # Args: $1=month_name (string, e.g., "Jan"), $2=day (integer)
  # Returns: 0 if day is valid (<= max days), 1 if invalid
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
  jan*) days=31 ;; feb*) days=28 ;;
  mar*) days=31 ;; apr*) days=30 ;;
  may*) days=31 ;; jun*) days=30 ;;
  jul*) days=31 ;; aug*) days=31 ;;
  sep*) days=30 ;; oct*) days=31 ;;
  nov*) days=30 ;; dec*) days=31 ;;
  *)
    echo "$0: Unknown month name $1" >&2
    exit 1
    ;;
  esac

  # The number is valid day.
  [ "$2" -lt 1 ] || [ "$2" -gt "$days" ] && return 1 || return 0
}

isLeapYear() {
  # Description: Determines if a year is a leap year using standard rules.
  # Args: $1=year (integer)
  # Returns: 0 if leap year, 1 if not
  year="$1"
  if [ "$((year % 4))" -ne 0 ]; then
    return 1 # Nope, not a leap year.
  elif [ "$((year % 400))" -eq 0 ]; then
    return 0 # Yes, it's a leap year.
  elif [ "$((year % 100))" -eq 0 ]; then
    return 1
  else
    return 0
  fi
}

# String Validation
validAlphaNum() {
   # Description: Validates if a string contains only alphanumeric characters.
   # Args: $1=string
   # Returns: 0 if valid (alphanumeric only), 1 if invalid
  validchars=${1//[^[:alnum:]]/}
  [ "$validchars" = "$1" ] && return 0 || return 1
}

monthNumToName() {
   # Description: Converts a month number (1-12) to its abbreviated name.
   # Args: $1=month_number (integer, 1-12)
   # Returns: Month name (e.g., "Jan") on stdout, 0 on success, exits on error
  case "$1" in
  1) month="Jan" ;; 2) month="Feb" ;;
  3) month="Mar" ;; 4) month="Apr" ;;
  5) month="May" ;; 6) month="Jun" ;;
  7) month="Jul" ;; 8) month="Aug" ;;
  9) month="Sep" ;; 10) month="Oct" ;;
  11) month="Nov" ;; 12) month="Dec" ;;
  *) error_exit "$0: Unknown month value $1" ;;
  esac
  echo "$month" && return 0
}

# Formatting
nicenumber() {
   # Description: Formats a number with thousand separators and optional decimal output.
   # Args: $1=number (string), $2=output_flag (opt, non-empty to echo result)
   # Returns: Formatted number on stdout if $2 set, else sets nicenum var
   separator=${1//[[:digit:]]/}
  [ -n "$separator" ] && [ "$separator" != "$DD" ] &&
    error_exit "$0 : Unknown decimal separator $separator encountered."

  # Note that we assume that '.' is the decimal separator in the INPUT value
  #   to this script. The decimal separator in the output value is '.' unless
  #   specified by the user with the -d flag.
  integer=$(echo "$1" | cut -d. -f1) # Left of the decimal
  decimal=$(echo "$1" | cut -d. -f2) # Right of the decimal

  # Check if number has more than the integer part.
  [ "$decimal" != "$1" ] && result="${DD:= '.'}$decimal" # There's a fractional part, so let's include it.

  thousands=$integer

  while [ "$thousands" -gt 999 ]; do
    remainder=$((thousands % 1000))

    # We need 'remainder' to bet three digits. Do we need to add zeros ?
    while [ ${#remainder} -lt 3 ]; do # Force leading zeros
      remainder="0$remainder"
    done

    result="${TD:=","}${remainder}${result}" # Builds right to left
    thousands=$((thousands / 1000))          # To left of remainder, if any
  done

  nicenum="${thousands}${result}"
  [ -n "$2" ] && echo "$nicenum"
}
