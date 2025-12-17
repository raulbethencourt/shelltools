#!/bin/bash

# remember -- An easy command line-based reminder pad.

rememberfile="$HOME/.remeber"

if [ "$#" -eq 0 ]; then
  # Prompt the user for input and append whatever they write to
  #   the rememberfile.
  echo "Enter note, en with ^D: "
  cat - >>"$rememberfile"
else
  # Append any arguments to the script on to the .remember file.
  echo "$@" >>"$rememberfile"
fi

exit 0
