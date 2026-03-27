#!/bin/bash

# cdf -- Do cd to directory using a list from zoxide and we will
#   do the choice with fzf.

searchr=$(
  zoxide query -l |
    fzf --tmux center,70%,60% -i --bind=tab:up --bind=btab:down \
      --padding 0 --margin 0 \
      --preview 'eza -lA --changed --color=always --icons=always {}' \
      --bind=ctrl-g:first --style full \
      --bind=ctrl-d:preview-half-page-down --bind=ctrl-u:preview-half-page-up \
      --prompt '󰀘  ' --info=hidden \
      --color 'prompt:#ea6962' \
      --color 'border:#414b50'
)

cmd="cd $searchr"
[ -n "$searchr" ] && eval "$cmd" || echo "Nothing found"
