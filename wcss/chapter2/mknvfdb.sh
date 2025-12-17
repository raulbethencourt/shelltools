#!/bin/bash

# mklocatedb -- Builds the locate database using find. User must be root
#   to run this script.

locatedb="/var/locate.db"

[ "$(whoami)" != "root" ] && {
  echo "Must be root to run this command." >&2 && exit 1
}

find / -print >$locatedb

exit 0
