#!/bin/bash

# fmt -- Text formatting utility that acts as a wrapper for nroff

help=1
while getopts "hyw:" opt; do
  # shellcheck disable=SC2220
  case "$opt" in
  h) help=0 ;;
  y) hyph=1 ;;
  w) width="$OPTARG" ;;
  esac
done
shift $(("$OPTIND" - 1))

[ "$#" -eq 0 ] || [ "$help" -eq 0 ] && {
  cat <<EOF >&2
Usage: $0 [OPTION]... [FILE]...
Formatts file lines to a specific width size.

  -h  show this help and quit
  -y  enable hyphenation for better fills 
  -w  chose you line width (default = 80)

Examples:
  fmt -h -w 72 file1.txt file2.txt
EOF
  exit 1
}

nroff <<EOF
.ll ${width:-80}
.na
.hy ${hyph:-0}
.pl 1
$(cat "$@")
EOF

exit 0
