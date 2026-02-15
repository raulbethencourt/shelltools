#!/bin/bash

. inpath.sh

echo_n() {
    if check_for_cmd_in_path printf; then
        printf "%s" "$*"
    else
        echo "$*" | tr -d '\n'
    fi
}

echon "$*"
