#!/bin/bash

# ANSI color -- Use these variables to make output in different colors
#   and formats. Color names that end with 'f' are foreground colors,
#   and those ending with 'b' are background colors.

initANSI() {
  # Foreground colors
  blackf=$(tput setaf 0)
  redf=$(tput setaf 1)
  greenf=$(tput setaf 2)
  yellowf=$(tput setaf 3)
  bluef=$(tput setaf 4)
  purplef=$(tput setaf 5)
  cyanf=$(tput setaf 6)
  whitef=$(tput setaf 7)

  # Background colors
  blackb=$(tput setab 0)
  redb=$(tput setab 1)
  greenb=$(tput setab 2)
  yellowb=$(tput setab 3)
  blueb=$(tput setab 4)
  purpleb=$(tput setab 5)
  cyanb=$(tput setab 6)
  whiteb=$(tput setab 7)

  # Bold, italic, underline and inverse style toggles
  boldon=$(tput smso)
  boldoff=$(tput rmso)
  italicon=$(tput sitm)
  italicoff=$(tput ritm)
  ulon=$(tput smul)
  uloff=$(tput rmul)
  inver=$(tput rev)

  reset=$(tput sgr0)
}
