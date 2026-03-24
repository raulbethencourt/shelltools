#!/bin/bash

# nvf -- Search a file from home directory and open it with nvim using fzf
#   to do the choce.

searchr=$(
  fd --type f --hidden --exclude .git . "$HOME/" |
    fzf --tmux center,70%,60% -i --bind=tab:up --bind=btab:down \
      --bind=ctrl-g:first --style full --info=inline \
      --prompt '󰀘  ' --info=hidden \
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
