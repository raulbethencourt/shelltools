#!/bin/bash

languages=$(echo "bash rust php lua js typescript sql" | tr ' ' '\n')
core_utils=$(echo "read xargs find fd mv sed awk rg grep tail df" | tr ' ' '\n')

selected=$(echo "$languages\n$core_utils" | fzf)
read -r "query?query: " query

if print "$languages" | grep -qs "$selected"; then
  cmd="curl cht.sh/$selected/$(echo "$query" | tr ' ' '+') & while [ : ]; do sleep 1; done"
else
  cmd="curl cht.sh/$selected~$query & while [ : ]; do sleep 1; done"
fi

tmux neww zsh -c "$cmd"
