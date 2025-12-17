#!/bin/bash

# agenda -- Scans through the user's .agenda file to see if there
#   are matches for the current or next day.

# shellcheck disable=SC1091
. "$SCRIPTSPATH"/library.sh && initANSI # Get colors.

agendafile="$HOME/.agenda"

checkDate() {
  #Create the possible default values that will match today.
  weekday="$1" day="$2" month="$3" year="$4"
  format1="$weekday" format2="$day$month" format3="$day$month$year"

  # And step through the file comparing dates...

  IFS="|" # The reads will naturally split at the IFS.

  # shellcheck disable=SC2154
  echo "${purplef}On the agenda for today:${reset}"

  while read -r date description; do
    [ "$date" = "$format1" ] || [ "$date" = "$format2" ] || [ "$date" = "$format3" ] && echo "  - $description"
  done <"$agendafile"
}

[ ! -e "$agendafile" ] && {
  # shellcheck disable=SC2154
  echo "${redf}$0:${reset} You don't seem to have an .agenda files. " >&2
  echo "To remedy this, please use 'addagenda' to add events." >&2
  exit 1
}

# Now let's get today's date...

eval "$(date '+weekday="%a" month="%b" day="%e" year="%G"')"

# shellcheck disable=SC2001
day="$(echo "$day" | sed 's/ //g')" # Remove possible leading space.
month="$(normalize "$month")"

checkDate "$weekday" "$day" "$month" "$year"

exit 0
