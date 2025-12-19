#!/bin/bash

# Initialize library
source "$SHELLTOOLSPATH"/lib/.toolbox

parse_options 0 FCURL_ \
  "--usage: Make curl request using saved endpoints." \
  "--directory:d=|default=$SHELLTOOLSPATH/restapi/:The rest directorie." \
  "--env-file:e=|default=$SHELLTOOLSPATH/restapi/.env:The env file to use." \
  "--file:f=|default="":The endpoint file to use. If you use this the rest directory has not use." \
  "--examples:    ${greenf}fcurl${reset}\n \
        ${greenf}fcurl${reset} -d /home/rabeta/tools/scripts/rest -e /home/rabeta/rest/.env" \
  -- "$@"
shift "$((TBOPTIND))"

# =================
# BEGIN MAIN SCRIPT
# =================

# Create secure temporary file that will be automatically removed on exit
ftmp=$(mktemp) || error_exit "Failed to create temporary file" 2
trap 'rm -f "${ftmp}"' EXIT

# Use default rest queries directory if not declared
[[ -d "$FCURL_DIRECTORY" ]] || error_exit "$FCURL_DIRECTORY directory not found." 2

# Search endpoint if not passed as option
if [ -z "$FCURL_FILE" ]; then
  # Make a selection from the list of manuals with fzf
  FCURL_FILE="$(getFileWithFzf "$FCURL_DIRECTORY")"
else
  [ ! -f "$FCURL_FILE" ] && error_exit "$FCURL_FILE file not found."
fi
FCURL_DIRECTORY=$(dirname "$FCURL_FILE")

# Use temporary file to do variables parsing
cat "$FCURL_FILE" >"$ftmp"

# Search env file in directory path
envfile=$(getEnvFileFromPath "$FCURL_DIRECTORY")
[ ! -f "$envfile" ] && error_exit "Environment file $envfile not found."
[ -z "$envfile" ] && envfile="$FCURL_ENV_FILE"

# Replace constants values
while IFS= read -r line; do
  [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]] && continue
  const=$(echo "$line" | awk -F '=' '{print $1}')
  ! grep "$const" "$ftmp" &>/dev/null && continue
  value=$(echo "$line" | awk -F '=' '{print $2}')

  safe_value=$(printf '%s\n' "$value" | sed 's/[\/&]/\\&/g')
  sed -i "s|{{$const}}|$safe_value|g" "$ftmp"
done <"$envfile"

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
