#!/bin/bash

# generate-golden.sh generates a golden testdata.
#
# USAGE:
#     generate-golden.sh [OPTIONS]
#
#
# OPTIONS:
# Options of help-bash.sh are available.
# This script runs `help-bash.sh -hXXX > testdata/golden/data.XXX.txt`
# XXX is OPTIONS without "-" and "h".

readonly HELP_BASH="./help-bash.sh"
readonly TR="${TR:-tr}"

readonly goldend="testdata/golden"

coerce_opts() {
    echo "$1" | $TR -d "-" | $TR -d "h"
}

readonly raw_opts="$(coerce_opts $1)"
readonly opts="-h${raw_opts}"
readonly output="${goldend}/data.${raw_opts}.txt"

$HELP_BASH "$opts" > "$output"
