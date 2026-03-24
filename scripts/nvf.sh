#!/bin/bash

# nvf -- Search a file from home directory and open it with nvim using fzf
#   to do the choce.

searchr=$(
  fd --type f --hidden --exclude .git . "$HOME/" |
    fzf --tmux center,80%,70% -i --bind=tab:up --bind=btab:down \
      --padding 0 --margin 0 \
      --bind=ctrl-g:first --style full --info=inline \
      --bind=ctrl-d:preview-half-page-down --bind=ctrl-u:preview-half-page-up \
      --prompt '󰀘  ' --info=hidden \
      --preview 'bat --style=full --color=always {}' \
      --preview-window 'right,55%' \
      --color 'prompt:#ea6962' \
      --color 'border:#414b50' \
      --color 'preview-border:#414b50' \
      --color 'list-border:#414b50' \
      --color 'input-border:#414b50' \
      --color 'header-border:#414b50'
)

cmd="nvim $searchr"
[ -n "$searchr" ] && {
  echo "$cmd" && eval "$cmd"
} || echo "Nothing found"
