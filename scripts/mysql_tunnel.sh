#!/bin/bash
set -e

CONFIG_FILE="$HOME/.ssh/.mysql_tunnel_config"

handle_error() {
  local error_message="$1"
  
  echo "Error: $error_message" >&2 && exit 1
}

create_tunnel() {
  local host=$1
  local local_port=$2
  
  ssh -f -N -L "$local_port":localhost:3306 "$host" || {
    handle_error "Failed to create SSH tunnel to $host" >&2 && exit 1
  }
}

select_host() {
  local host=""
  local tmp_file=""
  local selected_host=""

  hosts=$(grep "^Host " ~/.ssh/config | awk '{print $2}')
  [ -z "$hosts" ] && handle_error "No hosts found in SSH config"

  tmp_file=$(mktemp)
  tmux display-popup -E "echo \"$hosts\" | fzf > $tmp_file" || handle_error "Failed to display host selection popup"
  selected_host=$(cat "$tmp_file")
  rm "$tmp_file"

  [ -z "$selected_host" ] && handle_error "No host selected"
  echo "$selected_host"
}

get_or_assign_port() {
  local port
  local host=$1

  touch "$CONFIG_FILE"

  port=$(grep "^$host:" "$CONFIG_FILE" | cut -d':' -f2)

  [ -z "$port" ] && {
    port=$(comm -23 <(seq 49152 65535 | sort) <(cut -d':' -f2 "$CONFIG_FILE" | sort -u) |
      shuf | head -n 1) || handle_error "Failed to find an available port"

    echo "$host:$port" >>"$CONFIG_FILE"
  }
  echo "$port"
}

# =================
# BEGIN MAIN SCRIPT
# =================

host=$(select_host)
local_port=$(get_or_assign_port "$host")

create_tunnel "$host" "$local_port"

connection_url="mysql://localhost:$local_port"
echo "Connection URL: $connection_url"

