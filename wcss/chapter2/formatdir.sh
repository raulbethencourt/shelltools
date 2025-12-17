#!/bin/bash

# formatdir -- Outputs a directory listing in a friendly and useful format
#
# Note that you need to ensure "scriptbc" (Script #9) is in your current path
#   because it's invoked within the script more than once.

scriptbc=$(which scriptbc)
sizeGB=1048576
sizeMB=1024

# Function to format sizes in KB to KB, MB, or GB more readable output
readableSize() {
  if [ "$1" -ge "$sizeGB" ]; then
    $scriptbc -p 2 "$1" / "$sizeGB"
  elif [ "$1" -ge "$sizeMB" ]; then
    $scriptbc -p 2 "$1" / "$sizeMB"
  else
    echo "${1}KB"
  fi
}

# =================
# BEGIN MAIN SCRIPT
# =================

[ "$#" -gt 1 ] && echo "Usage: $0 [dirname]" >&2 && exit 1
[ "$#" -eq 1 ] && {                             # Specified a directory other than the current one ?
  cd "$@" || {                                  # The let's change to that one.
    echo "Directory: $1 doesn' exist" && exit 1 # Or quite if the directory doesn't exist.
  }
}

for file in *; do
  if [ -d "$file" ]; then
    size=$(("$(find "$file" -maxdepth 1 |
      wc -l |
      sed 's/[^[:digit:]]//g')" - 1))                 # I remove 1 coz find count actual directory.
    [ "$size" -eq 1 ] && ent="entry" || ent="entries" # Create var for singular or plural answer.
    echo "$file ($size $ent)"
  else
    # shellcheck disable=SC2012
    size="$(ls -sk "$file" | awk '{print $1}')"
    echo "$file ($(readableSize "$size"))"
  fi
done | column

exit 0
