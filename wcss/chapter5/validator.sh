#!/bin/bash

# validator -- Ensures that the PATH contains only valid directories
#    and then checks that all envireonment variables are valid.
#    Looks at SHELL, HOME, PATH, EDITOR, MAIL, and PAGER.

set -euo pipefail

# shellcheck disable=SC1091
. "$SCRIPTSPATH"/library.sh

errors=0

validate() {
  varname="$1"
  varvalue="$2"

  [ -z "$varvalue" ] && return

  if [ "${varvalue%"${varvalue#?}"}" = "/" ]; then
    [ ! -x "$varvalue" ] && {
      echo "** $varname set to $varvalue, but I cannot find executable;"
      ((errors++))
    }
  else
    in_path "$varvalue" "$PATH" && {
      echo "** $varname set to $varvalue, but I cannot find it in PATH."
      errors=$(("$errors" + 1))
    }
  fi
}

# =================
# BEGIN MAIN SCRIPT
# =================

[ ! -x "${SHELL:?"Cannot porceed without SHELL being defined."}" ] && {
  echo "** SHELL set to $SHELL, but I cannot find that executable."
  errors=$(("$errors" + 1))
}

[ ! -d "${HOME:?"You need to have your HOME to your home directory."}" ] && {
  echo "** HOME set to $HOME, but is not a directory."
  errors=$(("$errors" + 1))
}

# Our first interesting test: Are all the paths in PATH valid ?

oldIFS=$IFS
IFS=':' # IFS is the field separator. We'll change to ':'.

for directory in $PATH; do
  [ ! -d "$directory" ] && {
    echo "** PATH contains invalid directory $directory."
    errors=$(("$errors" + 1))
  }
done

IFS="$oldIFS" # Restore value for rest of the script.

# The following variables should each be a fully qualified path,
#   but they may be either undefined or a progname. Add additional
#   variables as necessary for you site and user community.
validate "EDITOR" "$EDITOR"
validate "MAILER" "$MAILER"
validate "PAGER" "$PAGER"

# And, finally, a different ending depending on whether errors > 0
[ "$errors" -gt 0 ] &&
  echo "Errors encountered. Please notify sysadmin for help." ||
  echo "Your envireonment checks out fine."

exit 0
