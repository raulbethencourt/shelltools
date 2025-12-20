#!/bin/bash

# Initialize library
source "$SHELLTOOLSPATH"/lib/.toolbox

parse_options 0 FMAN_ \
  "--usage: Show downloaded manuals." \
  "--directory:d=|default=$SHELLTOOLSPATH/manuals/:The manuals directory." \
  "--examples:    ${GREENF}fman${RESET}\n \
        ${GREENF}fman${RESET} -d ~/manuals" \
  -- "$@"
shift "$((TBOPTIND))"

# =================
# BEGIN MAIN SCRIPT
# =================

[ ! -d "$FMAN_DIRECTORY" ] && error_exit "Manual directory not found it." 1

# Make a selection from the list of manuals with fzf
getFileWithFzf "$FMAN_DIRECTORY"

suffix=$(echo "$file" | grep -oP '[^\.]*$')

case "$suffix" in
"md") glow -p "$FMAN_DIRECTORY/$file" ;;
"html") lynx "$FMAN_DIRECTORY/$file" ;;
"json") jq "$FMAN_DIRECTORY/$file" | less -R ;;
"pdf") pdftotext "$FMAN_DIRECTORY/$file" - | ccze -A | less -R ;;
*) error_exit "File type not handeled." 1 ;;
esac

exit 0
