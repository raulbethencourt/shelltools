#!/bin/bash

# fquota -- Disk quote analysis tool for Unix; assumes all user
#   accounts are >= UID 100

set -euo pipefail

readonly MAXDISKUSAGE=20000 # In megabytes

# Create temporary file to add the users info
# shellcheck disable=SC2155
readonly TMPFILE=$(mktemp)
trap 'rm -f "${TMPFILE}"' EXIT

cut -d: -f1,3 /etc/passwd | awk -F: '$2 > 99 {print $1}' >"$TMPFILE"

while IFS= read -r name; do
  [[ -z "${name}" ]] && continue

  /bin/echo -n "User $name exceeds disk quota. Disk usage is : "
  find / /usr /var /home -xdev -user "$name" -type f -ls 2>/dev/null |
    awk '{ sum += $7 } END  { print sum / (1024*1024) " Mbytes " }'
done <"$TMPFILE" |
  awk -v max="$MAXDISKUSAGE" '$NF > max { print $0 }'

exit 0
