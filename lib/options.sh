#!/bin/bash

create_section_constants() {
  local arg="$1"
  local sections=("$@")
  local section

  for section in "${sections[@]}"; do
    [[ "$arg" == --$section:* ]] && {
      local value="${arg#*:}"
      local var_name="TB_${section^^}_TXT" # Uppercase section (e.g., USAGE)
      eval "$var_name=\"$value\""
      return 0
    }
  done
  return 1
}
