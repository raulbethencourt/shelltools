#!/bin/bash

# remindme -- Searches a data file for matching lines or, if no
#   argument is specified, shows the entire contents of the data file.

rememberfile="$HOME/.remeber"

[ ! -f "$rememberfile" ] && {
  cat <<EOF >&2
$0: You don't seem to have a .remeber file.
To remedy this, please use "remember" to add reminders.
EOF
  exit 1
}

if [ "$#" -eq 0 ]; then
  # Display the whole rememberfile when not given any search criteria.
  # shellcheck disable=SC2002
  cat "$rememberfile" | ccze -A | less -R
else
  # Otherwise, search through the file for the given terms, and display
  #   the results neatly.
  grep -i -- "$@" "$rememberfile" | ccze -A | less -R
fi

exit 0
