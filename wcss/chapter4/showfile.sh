#!/bin/bash

# showfile -- Shows the content of a file, including additional useful info

# shellcheck disable=SC1091
. "$SCRIPTSPATH"/library.sh && initANSI # Get colors.

width=72

for input; do
  lines="$(wc -l <"$input" | sed 's/ //g')"
  chars="$(wc -c <"$input" | sed 's/ //g')"
  # shellcheck disable=SC2012
  owner="$(ls -ld "$input" | awk '{print $3}')"

  echo "----------------------------------------------------------------"
  echo "File $input ($lines lines, $chars characters, owned by $owner):"
  echo "----------------------------------------------------------------"

  while read -r line; do
    [ ${#line} -gt "$width" ] && {
      echo "$line" | fmt | sed -e '1s/^/ /' -e '2,$s/^/+ /'
      continue
    }
    echo "- $line"
  done <"$input"

  echo "----------------------------------------------------------------"
done | ${PAGER:more}

exit 0
