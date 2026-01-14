#!/bin/bash

# Initialize library
source "$SHELLTOOLSPATH"/lib/.toolbox

parse_options 0 FMAN_ \
  "--usage: Read the list of bns tests and allow dynamic choise using the utility fzf." \
  "--url:u=|default=http://localhost:8080:The manuals directory." \
  "--examples:    ${GREENF}tests${RESET}\n \
        ${GREENF}tests${RESET} -u https://aff.bluenotecrm.net/live/aff14" \
  -- "$@"
shift "$((TBOPTIND))"

# =================
# BEGIN MAIN SCRIPT
# =================

# Display list of tests trough fzf for selection.
test=$(
  find "$BNS_TOOLS"/tests -type f -name '*.curl' -print0 |
    xargs -0I {} basename {} |
    fzf
)
[ -z "$test" ] && exit 1 # Exit if we don't chose a test

# If we don't pass the url flag we use the "bns test" default
bns test -v --continue-on-fail "${url:-}" --curl "$BNS_TOOLS"/tests/"$test"

cat <<EOL
----------------------
To relaunch this test:
----------------------
bns test -v --continue-on-fail ${url:-} --curl "$BNS_TOOLS"/tests/$test
EOL

exit 0
