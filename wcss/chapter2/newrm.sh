#!/bin/bash

# newrm -- A replacement for the existing rm command.
#   This script provides ar rudimentary unremove capability by creating and
#   utilizing a new directory within the user's home directory. It can handle
#   directories of content as well as individual files. If the user specifies
#   the -f flag, files are removed and NOT archived.
#
# Big important Warning: You'll want a cron job or something similar to keep
#   the trash directories tamed. Otherwise, nothing will ever actually
#   be deleted from the system, and you'll run out of disk space!

archivedir="$HOME/.deleted-files"
realrm="$(which rm)"
copy="$(which cp) -R"

[ "$#" -eq 0 ] && exec "$realrm" # Our shell is replaced by /bin/rm.

# Parse all options looking for '-f'

flags=""
while getopts "hdfiPRrvW" opt; do
  # shellcheck disable=SC2220
  case "$opt" in
  f) exec "$realrm" "$@" ;;   # exec lets us exit this script directly.
  h) exec "$realrm" --help ;; # get real rm help.
  *) flags="$flags -$opt" ;;  # Other flags are for rm, not us.
  esac
done
shift $((OPTIND - 1))

# =================
# BEGIN MAIN SCRIPT
# =================

# Make sure that the $archivedir exists.
[ ! -d "$archivedir" ] && {
  [ ! -w "$HOME" ] && echo "$0 failed: can't create $archivedir in $HOME" >&2 && exit 1
  mkdir "$archivedir" && chmod 700 "$archivedir" # A little bit of privacy, please.
}

for arg; do
  newname="$archivedir/$(date "+%S.%M.%H.%d.%m").$(basename "$arg")"
  [ -f "$arg" ] || [ -d "$arg" ] && $copy "$arg" "$newname"
done

exec "$realrm" "$flags" "$@" 2>/dev/null # Our shell is replaced by realrm.
