#!/bin/bash

# toolong -- Feeds the fmt command oly those lines in the input stream
#   that are longer than the specified length

width=72

[ ! -r "$1" ] && {
  echo "Cannot read file $1" >&2
  echo "Usage: $0 filename" >&2
  exit 1
}

while read -r input; do
  if [ ${#input} -gt "$width" ]; then
    echo "$input" | fmt
  else
    echo "$input"
  fi
done <"$1"

exit 0
