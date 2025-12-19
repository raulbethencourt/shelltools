#!/bin/bash

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

print_progress() {
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

  printf "${prefix}${greenf}%s%s %s${reset} %${percentFormat}d%%${suffix}" "$bar" "$barEmpty" "$spinner" "$percent"
}

printcn() {
  # prints $2 times the $1 character
  c=${1:-\?}
  l=${2:-1}

  for ((i = 0; i < l; i++)); do
    printf "%s" "$c"
  done
}

print_usage_section_header() {
  printf "${marginText}${vertChar}${whitef}%s${reset}            \n" "$1"
  printcn "$horzChar" "$innerWidth"
  printf "%s\n" "$vertChar"
}

print_standard_section() {
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
    while [ $i -lt "$array_length" ]; do
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
  print_usage_section_header "OPTIONS"

  optLineFormat="${marginText}${vertChar}${tabText}%${optSpan}s    %s ${vertChar}\n"
  descrLineFormat="${marginText}${vertChar}${tabText}%${optSpan}s    %s ${vertChar}\n"
  overflowLineFormat="${marginText}${vertChar}${tabText}%${optSpan}s    %s ${vertChar}\n"
  overflowNextLineFormat="${marginText}${vertChar}${descrLeftMarginText}   %s ${vertChar}\n"

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
    if [ $fullDescrLen -gt $descrSpan ]; then
      printf "$overflowLineFormat" "$optTxt" ""
      printf "$overflowNextLineFormat" "${d:0:${descrSpan}}"
      currentDescrStart=$descrSpan
      while [ $currentDescrStart -lt $fullDescrLen ]; do
        printf "$overflowNextLineFormat" "${d:$((currentDescrStart)):${descrSpan}}"
        currentDescrStart=$((currentDescrStart + descrSpan))
      done
    else
      printf "$optLineFormat" "$optTxt" ""
      printf "$descrLineFormat" "" "$d"
    fi
    printf "\n"
  done

  printf "${marginText}${vertChar}${tabText}%s\n" "-??"
  printf "$descrLineFormat" "" "Display this help and exits"
}

toolbox_print_usage() {
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
    echo "While executing command :" && echo "    $CURRENT_COMMAND" && echo ""s
    echo "Usage : $(basename "$0") $MAIN_COMMAND" "$(print_all_options)" "$(print_all_positional)"
  }

  [ -n "$TB_USAGE_TXT" ] && echo -e "$TB_USAGE_TXT" | sed 's/_ABCBA_/ /g; s/\\n/\n/g'

  [ "$printLevel" -lt 2 ] && return

  print_standard_section "POSITIONAL" "$marginText" "$vertChar" "$horzChar" "$innerWidth"

  print_options_section

  printf "\n"

  print_standard_section "EXAMPLES" "$marginText" "$vertChar" "$horzChar" "$innerWidth"
  print_standard_section "REQUIREMENTS" "$marginText" "$vertChar" "$horzChar" "$innerWidth"
}
