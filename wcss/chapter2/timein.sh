#!/bin/bash

# timein -- Shows the current time in the specified time zone or
#   geographic zone. Without any argument, this shows UTC/GMT.
#   Use the word "list" to see a list of known geographic regions.
#   Note that it's possible to match zone directories (regions),
#   but that only time zone file (cities) are valid specifications.

# Time zone database ref: http://www.twinsun.com/tz/tz-link.html

scriptsPath="$HOME"/tools/scripts

# shellcheck disable=SC1091
. "$scriptsPath"/library.sh && initANSI # Get colors.

zonedir="/usr/share/zoneinfo"

[ ! -d "$zonedir" ] && {
  echo "No time zone database at $zonedir." >&2 && exit 1
}
[ -d "$zonedir/posix" ] && zonedir="$zonedir/posix" # Modern Linux systems

if [ $# -eq 0 ]; then
  timezone="UTC"
  mixedzone="UTC"
elif [ "$1" = "list" ]; then
  (
    echo "All known time zones and regions defined ont this sytem:"
    cd "$zonedir"
    find -L -- * -type f -print | xargs -0 -n 2 |
      awk '{ printf "  %-38s %-38s\n", $1, $2 }'
  ) | ccze -A | less -R && exit 0
else

  region="$(dirname "$1")"
  zone="$(basename "$1")"

  # Is the given time zone a direct match? If so, we're good to go.
  #   Otherwise we need to dig around a bit to find things.Start by
  #   just counting matches.

  matchcnt="$(find -L "$zonedir" -name "$zone" -type f -print |
    wc -l | sed 's/[^[:digit:]]//g')"


  # Check if at least one file matches.
  # shellcheck disable=SC2154
  if [ "$matchcnt" -gt 0 ]; then
    # But exit if more than one file matches.
    [ "$matchcnt" -gt 1 ] && {
      cat <<EOF >&2
${greenf}"$zone"${reset} matches more than one possible time zone record.
Please use ${greenf}'list'${reset} to see all known regions and time zones.
EOF
      exit 1
    }
    match="$(find -L "$zonedir" -name "$zone" -type f -print)"
    mixedzone="$zone"
  else # Maybe we can find a matching time zone region, rather than a specific
    #  time zone.
    # First letter capitalized, rest of word lowercase for region + zone
    mixedregion="$(echo "${region%"${region#?}"}" |
      tr '[:lower:]' '[:upper:]')\
      $(echo "${region#?}" | tr '[:upper:]' '[:lower:]')"
    mixedzone="$(echo "${zone%"${zone#?}"}" |
      tr '[:lower:]' '[:upper:]')\
      $(echo "${zone#?}" | tr '[:upper:]' '[:lower:]')"

    if [ "$mixedregion" != "." ]; then
      # Only look for specified zone in specified region
      #   to let users specify unique matches when there's
      #   more than one possibility (e.g., "Atlantic").
      match="$(find -L "$zonedir/$mixedregion" -type f -name "$mixedzone" -print)"
    else
      match="$(find -L "$zonedir" -type f -name "$mixedzone" -print)"
    fi

    # If file exactly matched the specified pattern
    [ -z "$match" ] && {
      # Check if the pattern was too ambiguous.
      if [ -n "$(find -L "$zonedir" -name "$mixedzone" -type d -print)" ]; then
        echo "The region ${greenf}\"$1\"${reset} has more than one time zone." >&2
      else # Or if it just didn't produce any matches at all.
        echo "Can't find an exact match for \"$1\"." >&2
      fi
      echo "Please use ${greenf}'list'${reset} to see all known regions and time zones." >&2 && exit 1
    }
  fi
  timezone="$match"
fi

# shellcheck disable=SC2001
nicetz=$(echo "$timezone" | sed "s|$zonedir/||g") # Pretty up the outuput.

echo It\'s "$(TZ="$timezone" date '+%A, %B %e, %Y, at %l:%M%p')" in "$nicetz"

exit 0
