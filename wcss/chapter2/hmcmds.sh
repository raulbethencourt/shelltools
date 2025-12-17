#!/bin/bash

# hmcmds -- A simple script to count how many executable
#   commands are in your current PATh

IFS=":"
count=0
nonex=0
for directory in $PATH; do
  [ -d "$directory" ] && {
    for cmd in "$directory"/*; do
      if [ -x "$cmd" ]; then
        count="$(("$count" + 1))"
      else
        nonex="$(("$nonex" + 1))"
      fi
    done
  }
done

echo "$count commands, and $nonex entries that weren't executable."

exit 0
