#!/bin/bash

# logrm -- Logs all file deletion requests unless the -s flag is used

removelog="/var/log/remove.log"

[ "$#" -eq 0 ] && {
  echo "Usage: $0 [-s] list of files or directories." >&2 && exit 1
}

if [ "$1" = "-s" ]; then
  shift # Silent operation requested ... don't log.
else
  echo "$(date): ${USER}:" "$@" >>"$removelog"
fi

/bin/rm "$@" && exit 0
