#!/bin/bash

# scriptbc -- Wrapper for 'bc' that returns the result of a calculation.

# Flag to add differents precisions.
if [ "$1" = "-p" ]; then
    precision=$2
    shift 2
else
    precision=2 # Default
fi

bc -q -l <<EOF
    scale=$precision
    $*
    quit
EOF

exit 0
