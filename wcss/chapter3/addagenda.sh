#!/bin/bash

# addagenda -- Promts the user to add a new event for the agenda script

# shellcheck disable=SC1091
. "$SCRIPTSPATH"/library.sh && initANSI # Get colors.

agendafile="$HOME/.agenda"

isDayName() {
  #Return 0 if all is well, 1 on error.
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
  sun* | mon* | tue* | wed* | thu* | fri* | sat*) return 0 ;;
  *) return 1 ;;
  esac
}

isMonthName() {
  #Return 0 if all is well, 1 on error.
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
  jan* | fev* | mar* | avr* | mai | jun*) return 0 ;;
  jul* | aut | sep* | oct* | nov* | dec*) return 0 ;;
  *) return 1 ;;
  esac
}

[ ! -w "$HOME" ] && error_exit "$0: cannot write in your home directory ($HOME)" 2

# shellcheck disable=SC2154
echo "${purplef}Agenda:${reset} The Unix Remainder Service"

/bin/echo -n "${purplef}Date of event (day mon, day month year, or dayname):${reset} "
# shellcheck disable=SC2034
read -r word1 word2 word3 junk

if isDayName "$word1"; then
  [ -n "$word2" ] && error_exit "Bad dayname format, just specify the day name by itself." 2
  date="$(normalize "$word1")"
else
  [ -z "$word2" ] && error_exit "Bad dayname format, unknown day name specified." 2

  # shellcheck disable=SC2001
  [ -n "$(echo "$word1" | sed 's/[[:digit:]]//g')" ] && error_exit "Bad date format, please specify day first, by day number." 2

  [ "$word1" -lt 1 ] || [ "$word1" -gt 31 ] && error_exit "Bad date format, day number can only be in range 1-31." 2

  ! isMonthName "$word2" && error_exit "Bad date format, unknown month name specified." 2

  word2="$(normalize "$word2")"

  if [ -z "$word3" ]; then
    date="$word1$word2"
  else
    # shellcheck disable=SC2001
    if [ -n "$(echo "$word3" | sed 's/[[:digit:]]//g')" ]; then
      error_exit "Bad date format, third field should be year" 2
    elif [ "$word3" -lt 2000 ] || [ "$word3" -gt 2500 ]; then
      error_exit "Bad date format, year value should be 2000-2500" 2
    fi
    date="$word1$word2$word3"
  fi
fi

/bin/echo -n "${purplef}One-line description:${reset} "
read -r description

# Ready to write to data file

# shellcheck disable=SC2001
echo "$(echo "$date" | sed 's/ //g')|$description" >>"$agendafile"

exit 0
