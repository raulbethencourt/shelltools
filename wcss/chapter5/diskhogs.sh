#!/bin/bash

# diskhogs -- Disk quote analysis tool for Unix; assumes all user
#   accounts are >= UID 100. Emails a message to each violating user
#   and reports a summary to the screen.

set -euo pipefail

# shellcheck disable=SC1091
. "$SCRIPTSPATH"/library.sh

readonly MAXDISKUSAGE=20000 # In megabytes

for cmd in find awk mail fmt cut; do
  command -v "$cmd" >/dev/null 2>&1 || {
    error_exit "Required command '$cmd' not found."
  }
done

# shellcheck disable=SC2155
readonly USER_LIST=$(mktemp)
trap 'rm -f "${USER_LIST}"' EXIT
# shellcheck disable=SC2155
readonly VIOLATORS=$(mktemp)
trap 'rm -f "${VIOLATORS}"' EXIT

cut -d: -f1,3 /etc/passwd | awk -F: '$2 > 99 {print $1}' >"$USER_LIST"

while IFS= read -r name; do
  [[ -z "${name}" ]] && continue

  /bin/echo -n "k $name exceeds disk quota. Disk usage is : "
  find / /usr /var /home -xdev -user "$name" -type f -print0 2>/dev/null |
    xargs -0 ls -l |
    awk '{ sum += $7 } END  { print sum / (1024*1024) " Mbytes " }'
done <"$USER_LIST" |
  awk -v max="$MAXDISKUSAGE" '$NF > max { print $0 }' >"$VIOLATORS"

[ ! -s "$VIOLATORS" ] && {
  echo "No users exceed the disk quota of ${MAXDISKUSAGE}MB"
  exit 0
}

while read -r account usage; do
  cat <<EOF | fmt | mail -s "Warning: $account Exceeds Quota " "$account"
Your disk usage is ${usage}MB, but you have been allocated only
${MAXDISKUSAGE}MB. This means that you need to delete some of your 
files, compress your files (see 'gzip' or 'bzip2' for powerful and
easy-to-use compression programs), or talk with us about increasing
your disk allocation.

Thanks for your cooperation in this matter.

Your friendly neighborhood sysadmin,
EOF

  echo "Account $account has $usage MB of disk space. User notified."
done <"$VIOLATORS"

exit 0
