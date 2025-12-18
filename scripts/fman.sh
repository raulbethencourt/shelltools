#!/bin/bash

# Initialize library
[ -f "$SHELLTOOLSPATH"/lib/.toolbox ] && source "$SHELLTOOLSPATH"/lib/.toolbox
initANSI # Get colors.

parse_options 0 FMAN_ \
  "--usage: Show downloaded manuals.\n \
${purplef}E.g${reset} ${greenf}$(basename $0)${reset} [OPTION]..." \
  "--directory:d=|default=$SHELLTOOLSPATH/manuals/:The manuals directory." \
  "--examples:    ${greenf}fman${reset}\n \
        ${greenf}fman${reset} -d ~/manuals" \
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
"md") glow -p "$dir/$file" ;;
"html") lynx "$dir/$file" ;;
"json") jq "$dir/$file" | less -R ;;
"pdf") pdftotext "$dir/$file" - | ccze -A | less -R ;;
*) error_exit "File type not handeled." 1 ;;
esac

exit 0
