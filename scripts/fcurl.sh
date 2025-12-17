#!/bin/bash

# shellcheck disable=SC1091
. "$SCRIPTSPATH/library.sh" && initANSI # Get colors.

help=1
restdir=""
envFile=""
endpointFile=""

while getopts "hvd:e:f:" opt; do
  # shellcheck disable=SC2220
  case "$opt" in
  h) help=0 ;;
  v) verbose="-v" ;;
  d) restdir="$OPTARG" ;;
  e) envFile="$OPTARG" ;;
  f) endpointFile="$OPTARG" ;;
  *)
    error_exit "Invalid option: -${OPTARG}" 2
    ;;
  esac
done
shift $((OPTIND - 1))

case "$help" in
0)
  cat <<EOF >&2
${purplef}Usage:${reset} $0 [OPTION]...
Launch curl queries from a files using fzf for selection.

  -h  show this help and quit
  -d  the rest directorie (default=\$HOME/tools/scripts/rest)
  -e  the env file to use (default=\$HOME/tools/scripts/rest/.env)
  -f  the endpoint file to use (default=\$HOME/tools/scripts/rest/endpoint.sh)
      If you use this the rest directory has not use.

${purplef}Examples:${reset}
  ${greenf}fcurl${reset}
  ${greenf}fcurl -d /home/rabeta/tools/scripts/rest -e /home/rabeta/rest/.env
EOF
  exit 1
  ;;
esac

# =================
# BEGIN MAIN SCRIPT
# =================

# Create secure temporary file that will be automatically removed on exit
ftmp=$(mktemp) || error_exit "Failed to create temporary file" 2
trap 'rm -f "${ftmp}"' EXIT

# Use default rest queries directory if not declared
restdir=${restdir:-"$HOME/tools/scripts/rest"}
[ -d "$restdir" ] || error_exit "$restdir directory not found." 2

# Search endpoint if not passed as option
if [ -z "$endpointFile" ]; then
  # Make a selection from the list of manuals with fzf
  getFileWithFzf "$restdir"
  endpointFile="$dir/$file"
else
  [ ! -f "$endpointFile" ] && error_exit "$endpointFile file not found."
  dir=$(dirname "$endpointFile")
fi

# Use temporary file to do variables parsing
cat "$endpointFile" >"$ftmp"

# Search env file in directory path
[ -z "$envFile" ] && getEnvFileFromPath "$dir"
[ ! -f "$envFile" ] && error_exit "Environment file $envFile not found."

# Replace constants values
while IFS= read -r line; do
  echo "$line" | grep -F "#" &>/dev/null || [ -z "$line" ] && continue
  const=$(echo "$line" | awk -F '=' '{print $1}')
  ! grep "$const" "$ftmp" &>/dev/null && continue
  value=$(echo "$line" | awk -F '=' '{print $2}')

  safe_value=$(printf '%s\n' "$value" | sed 's/[\/&]/\\&/g')
  sed -i "s|{{$const}}|$safe_value|g" "$ftmp"
done <"$envFile"

# shellcheck disable=SC1090
source "$ftmp"

[ -z "${QUERY:-}" ] && error_exit "QUERY variable not defined in endpoint file."

# Create curl command before executing
CURL_CMD="curl ${verbose:-} --location \"$QUERY\""
[ -n "${CMD_OVERLOAD:-}" ] && CURL_CMD="$CURL_CMD $CMD_OVERLOAD"

# shellcheck disable=SC2086
! response=$(eval "$CURL_CMD") && error_exit "curl command failed: $response." 2

echo "$response"

exit 0
