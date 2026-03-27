#!/bin/bash
# shellcheck disable=SC2015

# Initialize library
source "$SHELLTOOLSPATH"/lib/.toolbox

searchr=$(
  tldr --list |
    sed 's/,/\n/g' |
    fzf --tmux center,80%,70% -i --bind=tab:up --bind=btab:down \
      --padding 0 --margin 0 \
      --bind=ctrl-g:first --style full \
      --bind=ctrl-d:preview-half-page-down --bind=ctrl-u:preview-half-page-up \
      --prompt '󰀘  ' --info=hidden \
      --preview "tldr -t ocean {1} " --preview-window=right,70% \
      --preview-window 'right,55%' \
      --color 'prompt:#ea6962' \
      --color 'border:#414b50'
)

[ -n "$searchr" ] && {
  tldr "$searchr" && exit 0
} || error_exit "Nothing found"
