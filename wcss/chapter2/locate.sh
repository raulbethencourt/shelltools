#!/bin/bash

# locate -- Searches the locate database for the specified pattern.

# shellcheck disable=SC1091
. "$SCRIPTSPATH"/library.sh && initANSI # Get colors.

locatedb="/var/locate.db"

[ "$#" -eq 0 ] && echo "Usage: $(basename "$0") [FILE]..." >&2 && exit 1
[ ! -f "$locatedb" ] && echo "The locate.db file doesn't exist." >&2 && exit 1

# Search in db and display output with colors.
# shellcheck disable=SC2154
grep --color=always -i "$@" "$locatedb" |
  xargs -I {} echo "${cyanf}"{}"${reset}" || exit 1
