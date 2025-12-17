#!/bin/bash

# validdate -- Validates a date, taking into account leap year rules

normdate="normdate.sh"

exceedDaysInMonth() {
    # Given a month name and day number in that month, this function will
    #   return 0 if the specified day value is less than or equal to the
    #   max days in the month; 1 otherwise.

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

    [ "$2" -lt 1 ] || [ "$2" -gt "$days" ] && return 1 || return 0 # The number is valid day.
}

isLeapYear() {
    # This function returns 0 if the specified year is a leap year;
    #   1 otherwise.
    #
    # The formula for chequing whether a year is a leap year is :
    #   1. Years not divisible by 4 are not leap years.
    #   2. Years divisible by 4 and by 400 are leap years.
    #   3. Years divisible by 4, not divisible by 400, but divisible
    #      by 100 are not leap years.
    #   4. All other years divisible by 4 are leap years.

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

[ "${BASH_SOURCE[*]}" = "$0" ] && {
    [ "$#" -ne 3 ] && {
        echo "Usage: $0 month day year" >&2
        echo "Typical input formats are August 3 1962 and 8 3 1962" >&2
        exit 1
    }

    # Normalize date and store the return value to check for errors.

    newdate="$(./$normdate "$@")"

    [ "$?" -eq 1 ] && exit 1 # Error condition already reported by normdate

    # Split the normalized date fromat, where
    #   first word = month, second word = day, third word = year.

    month="$(echo "$newdate" | cut -d\  -f1)"
    year="$(echo "$newdate" | cut -d\  -f3)"

    # Now that we have a normalized date, let's check whether the
    #   day value is legal and valid (e.g., not Jan 36).
    ! exceedDaysInMonth "$month" "$2" && {
        if [ "$month" = "Feb" ] && [ "$2" -eq 29 ]; then
            ! isLeapYear "$3" && {
                echo "$0: $3 is not a leap year, so Feb doesn't have 29 days." >&2 && exit 1
            }
        else
            echo "$0: bad day value: $month doesn't have $2 days." >&2 && exit 1
        fi
    }

    echo "Valid date: $newdate" && exit 0
}
