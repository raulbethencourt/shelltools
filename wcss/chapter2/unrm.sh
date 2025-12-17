#!/bin/bash

# unrm -- Searches the deleted files archive for the specified file or
#   directory. If there is more than one matching result, it shows a list
#   of results ordered by timestamp and lets the user specify which one
#   to restore.

archivedir="$HOME/.deleted-files"
realrm="$(which rm)"
move="$(which mv)"

dest="$(pwd)"

[ ! -d "$archivedir" ] && echo "$0: No deleted files directory: nothin to unrm" >&2 && exit 1

cd "$archivedir" || {
  echo "Can't cd into $archivedir" >&2 && exit 1
}

# If given no arguments, just show a listing of the deleted files.
[ "$#" -eq 0 ] && {
  echo "Contents of your deleted files archive (sorted by date):"
  find . -maxdepth 1 -mindepth 1 |
    sed -e 's/\([[:digit:]][[:digit:]]\.\)\{5\}//g' -e 's/^/  /'
  exit 0
}

# Otherwise, we must have a user-specified pattern to work width.
#   Let's see if the pattern matches more than one file or directory
#   in the archive.

matches="$(find . -maxdepth 1 -mindepth 1 -name "*$1" 2>/dev/null | wc -l)"

[ "$matches" -eq 0 ] && {
  echo "No match for \"$1\" in the deleted file archive." >&2 && exit 1
}

if [ "$matches" -gt 1 ]; then
  echo "More than one file or directory match in the archive:"
  index=1
  # shellcheck disable=SC2045
  for name in $(ls -td -- *"$1"); do
    datetime="$(echo "$name" | cut -c1-14 |
      awk -F. '{ print $5"/"$4" at "$3":"$2":"$1 }')"
    filename="$(echo "$name" | cut -c16-)"
    if [ -d "$name" ]; then
      filecount="$(find "$name" -maxdepth 1 -mindepth 1 | wc -l | sed 's/[^[:digit:]]//g')"
      echo " $index)   $filename   (contents = ${filecount} items," \
        " delted = $datetime)"
    else
      # shellcheck disable=SC2012
      size="$(ls -sdk1 "$name" | awk '{print $1}')"
      echo " $index)   $filename   (size = ${size}Kb, deleted = $datetime)"
    fi
    index=$((index + 1))
  done
  echo ""
  /bin/echo -n "Which version of $1 should I restore ('0' to quit)? [1] : "
  read -r desired
  # shellcheck disable=SC2001
  [ -n "$(echo "$desired" | sed 's/[[:digit:]]//g')" ] && {
    echo "$0: Restore canceled by user: invalid input." >&2 && exit 1
  }
  [ "${desired:=1}" -ge "$index" ] && {
    echo "$0: Restore canceled by user: index value too big." >&2 && exit 1
  }
  [ "$desired" -eq 0 ] && echo "$0: Restore canceled by user." >&2 && exit 1

  # shellcheck disable=SC2012
  retore="$(ls -td1 -- *"$1" | sed -n "${desired}p")"

  [ -e "$dest/$1" ] && {
    echo "\"$1\" already exists in this directory. Cannot overwrite." >&2 && exit 1
  }

  /bin/echo -n "Restoring file \"$1\"..."
  $move "$retore" "$dest/$1"
  echo "done."

  /bin/echo -n "Delete the additional copies of this file? [y] "
  read -r answer

  if [ "${answer:=y}" = "y" ]; then
    $realrm -rf -- *"$1" && echo "Deleted."
  else
    echo "Additional copies retained."
  fi
else
  [ -e "$dest/$1" ] && {
    echo "\"$1\" already exists in this directory. Cannot overwrite." >&2 && exit 1
  }

  restore="$(ls -d -- *"$1")"

  /bin/echo -n "Restoring file \"$1\"..."
  $move "$retore" "$dest/$1"
  echo "done."
fi

exit 0
