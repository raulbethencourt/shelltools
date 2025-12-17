#!/bin/bash

# nvf -- Search a file from home directory and open it with nvim using fzf
#   to do the choce.

searchr=$(
  fd --type f --hidden --exclude .git . "$HOME/" |
    fzf-tmux -p 80%,60% -i --bind=tab:up --bind=btab:down \
      --bind=ctrl-g:first \
      --preview "bat --color=always --style=numbers --line-range=:500 {}"
)

cmd="nvim $searchr"
[ -n "$searchr" ] && {
  echo "$cmd" && eval "$cmd"
} || echo "Nothing found"
