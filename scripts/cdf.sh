#!/bin/bash

# cdf -- Do cd to directory using a list from zoxide and we will
#   do the choice with fzf.

searchr=$(
  zoxide query -l |
    fzf-tmux -p 60%,50% -i --bind=tab:up --bind=btab:down \
      --bind=ctrl-g:first
)

cmd="cd $searchr"
[ -n "$searchr" ] && {
  echo "$cmd" && eval "$cmd"
} || echo "Nothing found"
