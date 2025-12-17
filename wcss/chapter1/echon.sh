#!/bin/bash

. inpath.sh

echon() {
    if checkForCmdInPath printf; then
        printf "%s" "$*"
    else
        echo "$*" | tr -d '\n'
    fi
}

echon "$*"
