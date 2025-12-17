#!/bin/bash

# filelock -- A flexible file-locking mechanism

retries="10"           # Default number of retries
action="lock"          # Default action

while getopts "lur:" opt; do
  # shellcheck disable=SC2220
  case "$opt" in
  l) action="lock" ;;
  u) action="unlock" ;;
  r) retries="$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

[ "$#" -eq 0 ] && { # Output a multiline error message to stdout.
  cat <<EOF >&2
Usage: $0 [-l|-u] [-r retries] LOCKFILE
Where -l requests a lock (the default), -u requests an unlock, -r X 
specifies a max number of retries before it fails (default = $retries).
EOF
  exit 1
}

# Ascertain if we have the lockfile command.

! which lockfile | grep -q '^no' && {
  echo "$0 failed: 'lockfile' utitlity not found in PATH." >&2
  exit 1
}

if [ "$action" = "lock" ]; then
  ! lockfile -1 -r "$retries" "$1" 2 >/dev/null && {
    echo "$0: Failed: Couldn't create lockfile in time." >&2
    exit 1
  }
else # Action = unlock.
  [ ! -f "$1" ] && {
    echo "$0: Warning: lockfile $1 doesn't exist to unlock" >&2
    exit 1
  }
  rm -f "$1"
fi

exit 0
