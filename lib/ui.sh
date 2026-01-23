#!/bin/bash
# UI utility functions for shell toolbox (colors, progress, usage printing)

# ANSI Color Constants
# shellcheck disable=SC2034,SC2155
readonly BLACKF="$(tput setaf 0)"
readonly REDF="$(tput setaf 1)"
readonly GREENF="$(tput setaf 2)"
readonly YELLOWF="$(tput setaf 3)"
readonly BLUEF="$(tput setaf 4)"
readonly PURPLEF="$(tput setaf 5)"
readonly CYANF="$(tput setaf 6)"
readonly WHITEF="$(tput setaf 7)"

readonly BLACKB="$(tput setab 0)"
readonly REDB="$(tput setab 1)"
readonly GREENB="$(tput setab 2)"
readonly YELLOWB="$(tput setab 3)"
readonly BLUEB="$(tput setab 4)"
readonly PURPLEB="$(tput setab 5)"
readonly CYANB="$(tput setab 6)"
readonly WHITEB="$(tput setab 7)"

readonly BOLDON="$(tput smso)"
readonly BOLDOFF="$(tput rmso)"
readonly ITALICON="$(tput sitm)"
readonly ITALICOFF="$(tput ritm)"
readonly ULON="$(tput smul)"
readonly ULOFF="$(tput rmul)"
readonly INVER="$(tput rev)"

readonly RESET="$(tput sgr0)"

# Progress Display
print_progress() {
  # Displays a progress bar with percentage and spinner.
  # Args: $1=current (int), $2=full (int), $3=bar_size (opt, default 28)
  # Returns: prints progress bar to stdout
  BAR_FULLSIZE=${3:-28}
  BAR_FULLSIZE=$((BAR_FULLSIZE - 8))
  current=$1
  full=$2
  prefix="\r["
  suffix="]"
  percentFormat=""
  sp=""
  TB_SPIN_PROGRESS=${TB_SPIN_PROGRESS:-1}
  spinner="${sp:TB_SPIN_PROGRESS++%${#sp}:1}"

  percent=$((current * 100 / full))
  barLength=$((current * BAR_FULLSIZE / full))

  if [ $percent -ge 100 ]; then
    suffix="\n"
    spinner=""
  elif [ $percent -lt 10 ]; then
    percentFormat="2"
  fi

  bar=$(printf "%${barLength}.s" " " | sed "s/ //g")
  barEmpty=$(printf "%$((BAR_FULLSIZE - barLength)).s" " ")

  printf "${prefix}${GREENF}%s%s %s${RESET} %${percentFormat}d%%${suffix}" "$bar" "$barEmpty" "$spinner" "$percent"
}

# Text Utilities
printcn() {
  # Prints a character a specified number of times.
  # Args: $1=character (opt, default '?'), $2=count (opt, default 1)
  # Returns: prints repeated character to stdout
  c=${1:-\?}
  count=${2:-1}

  for ((i = 0; i < count; i++)); do
    printf "%s" "$c"
  done
}

# Usage Printing
print_usage_section_header() {
  # Prints a formatted header for a usage section (e.g., OPTIONS).
  # Args: $1=section_title
  # Returns: prints header to stdout (assumes marginText, vertChar, horzChar, innerWidth set)
  printf "${marginText}${vertChar}${WHITEF}%s${RESET}            \n" "$1"
  printcn "$horzChar" "$innerWidth"
  printf "%s\n" "$vertChar"
}

print_standard_section() {
  # Prints a standard usage section (e.g., EXAMPLES) if data exists.
  # Args: $1=section_title, $2=marginText, $3=vertChar, $4=horzChar, $5=innerWidth
  # Returns: prints section to stdout if TB_${title}_TXT array has elements
  title="$1"
  marginText="$2"
  vertChar="$3"
  horzChar="$4"
  innerWidth="$5"

  local section_var="TB_${title}_TXT"

  # Check array length dynamically
  local array_length
  # shellcheck disable=SC1087
  eval "array_length=\${#$section_var[@]}"
  if [ "$array_length" -gt 0 ]; then
    print_usage_section_header "$title"

    # Loop over array dynamically
    local i=0
    while [ "$i" -lt "$array_length" ]; do
      local text
      # shellcheck disable=SC1087
      eval "text=\${$section_var[$i]}"
      echo -e "${marginText}$text" | sed 's/_ABCBA_/ /g' | sed 's/\\n/\n/g'
      printf "\n"
      i=$((i + 1))
    done
  fi
}

print_options_section() {
  # Prints the OPTIONS section with formatted option descriptions.
  # Args: none (assumes global toolbox arrays set)
  # Returns: prints options section to stdout
  print_usage_section_header "OPTIONS"

  for idx in "${toolbox_IDXES[@]}"; do
    d=$(echo "${toolbox_DESCRS[$idx]}" | sed 's/_ABCBA_/ /g')
    s1=${toolbox_SHORTS[$idx]}
    s=${s1%\=}
    if [ "$s1" != "$s" ]; then
      value=$(print_option_values "${toolbox_LONGS[$idx]}" "" 1)
      value="=${value} (default=${toolbox_DEFAULT[$idx]/EMPTY_VALUE//})"
    else
      value=""
    fi

    fullDescrLen=${#d}
    optTxt="${toolbox_LONGS[$idx]}$value"
    [ "$s" != "-" ] && optTxt="${s}, $optTxt"
    if [ "$fullDescrLen" -gt "$descrSpan" ]; then
      printf '%s%s%s%*s    %s %s\n' "$marginText" "$vertChar" "$tabText" "$optSpan" "$optTxt" "" "$vertChar"
      printf '%s%s%s   %s %s\n' "$marginText" "$vertChar" "$descrLeftMarginText" "${d:0:${descrSpan}}" "$vertChar"
      currentDescrStart=$descrSpan
      while [ "$currentDescrStart" -lt "$fullDescrLen" ]; do
        printf '%s%s%s   %s %s\n' "$marginText" "$vertChar" "$descrLeftMarginText" "${d:$((currentDescrStart)):${descrSpan}}" "$vertChar"
        currentDescrStart=$((currentDescrStart + descrSpan))
      done
    else
      printf '%s%s%s%*s    %s %s\n' "$marginText" "$vertChar" "$tabText" "$optSpan" "$optTxt" "" "$vertChar"
      printf '%s%s%s%*s    %s %s\n' "$marginText" "$vertChar" "$tabText" "$optSpan" "" "$d" "$vertChar"
    fi
    printf "\n"
  done

  printf "${marginText}${vertChar}${tabText}%s\n" "-h, --help"
  printf '%s%s%s%*s    %s %s\n' "$marginText" "$vertChar" "$tabText" "$optSpan" "" "Display this help and exits" "$vertChar"
}

toolbox_print_usage() {
  # Prints formatted usage information for a toolbox script.
  # Args: $1=printLevel (opt, default 1), $2=isError (opt, default 0), $@=custom_header_lines
  # Returns: prints usage to stdout
  printLevel="${1:-1}"
  isError="${2:-0}"
  shift 2
  horzChar=" "
  vertChar=" "
  displayWidth=$(/usr/bin/tput cols)
  displayWidth=$((displayWidth / 2 * 2))

  leftMargin=5
  tabSize=3
  marginText=$(printcn " " $leftMargin)
  tabText=$(printcn " " $tabSize)
  innerWidth=$((displayWidth - 2 - leftMargin * 2))
  shortSpan=2
  optSpan=$((shortSpan + 2))
  descrLeftMargin=$((optSpan + tabSize + 1))
  descrLeftMarginText=$(printcn " " $descrLeftMargin)
  descrSpan=$((innerWidth - descrLeftMargin - 1 - 4))

  for line in "$@"; do
    [ -n "$line" ] && echo "$line"
    shift
  done

  [ "$isError" -gt 0 ] && {
    echo "While executing command :" && echo "    $CURRENT_COMMAND" && echo ""
    echo "Usage : $(basename "$0") $MAIN_COMMAND" "$(print_all_options)" "$(print_all_positional)"
  }

  [ -n "$TB_USAGE_TXT" ] && echo -e "$TB_USAGE_TXT" | sed 's/_ABCBA_/ /g; s/\\n/\n/g'

  printf "\n"

  [ "$printLevel" -lt 2 ] && return

  print_standard_section "POSITIONAL" "$marginText" "$vertChar" "$horzChar" "$innerWidth"

  print_options_section

  printf "\n"

  print_standard_section "EXAMPLES" "$marginText" "$vertChar" "$horzChar" "$innerWidth"
  print_standard_section "REQUIREMENTS" "$marginText" "$vertChar" "$horzChar" "$innerWidth"
}
