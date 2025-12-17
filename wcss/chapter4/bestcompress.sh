#!/bin/bash

# bestcompress -- Given a file, tries compressing it with all the available
#   compression tools and keeps the compressed file that's smallest,
#   reporting the result to the user. If -a isn't specified, bestcompress
#   skips compressed files in the input stream.

# shellcheck disable=SC1091
. "$SCRIPTSPATH"/library.sh && initANSI # Get colors.

gz="gzip" bz="bzip2"
gzout="/tmp/bestcompress.$$.gz"
bzout="/tmp/bestcompress.$$.bz"
skipcompressed=1

[ "$1" = "-a" ] && skipcompressed=0 && shift
[ "$#" -eq 0 ] && usage_exit "[-a] file or files to optimally compress."

trap '/bin/rm -f $gzout $bzout' EXIT

for name in "$@"; do
  [ ! -f "$name" ] && {
    echo "$(basename "$0"): file $name not found. Skipped." >&2
    continue
  }

  [ "$(echo "$name" | grep -E '(\.Z$|\.gz$\.bz2$)')" != "" ] && {
    if [ "$skipcompressed" -eq 1 ]; then
      echo "Skipped file ${name}: It's already compressed."
      continue
    else
      echo "Warning: Trying to double-compress ${name}."
    fi
  }

  # Try compressing all three files in parallel.
  $gz <"$name" >$gzout &
  $bz <"$name" >$bzout &

  wait # Wait until all compressions are done.

  # Figure out which compressed best.
  # shellcheck disable=SC2012
  smallest="$(ls -l "$name" $gzout $bzout |
    awk '{print $5"="NR}' | sort -n | cut -d= -f2 | head -1)"

  case "$smallest" in
  1) echo "No space savings by compressing $name. Left as is." ;;
  2)
    echo "Best compression is with gzip. File renamed ${name}.gz"
    mv "$gzout" "${name}.gz"
    ;;
  3)
    echo "Best compression is with bzip2. File renamed ${name}.bz"
    mv "$bzout" "${name}.bz"
    ;;
  esac
done

exit 0
