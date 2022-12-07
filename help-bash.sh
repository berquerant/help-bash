#!/bin/bash

# help-bash.sh displays the things like documentation comments in .sh file.
#
# USAGE:
#   help-bash.sh [OPTIONS] [PATH]
#
#
# ARGS:
#     <PATH>
#         A file to display documentations.
#
#
# OPTIONS:
#     -f
#         Displays top-level (outside of any statements) functions documentations.
#     -r
#         Displays top-level variables documentations.
#     -h
#         Prints help information.
#     -v
#         Prints version information.
#     -t
#         Threshold to determine whether to display the top-level comments.
#         e.g. the value is 3 then displays 3 or more lines of top-level comments.
#         Default is 5.
#     -d
#         Enable debug logs.
#
#
# ENVIRONMENT VARIABLES:
#     AWK
#         awk command.
#     GREP
#         grep command.

# Version of this script.
readonly version="0.1.0"

readonly AWK="${AWK:-awk}"
readonly GREP="${GREP:-grep}"

# For -d option.
debug=0
# For -t option.
toplevel=5
# For -f option.
needfunc=0
# For -r option.
needvar=0
# For -h option.
do_help=false
# For -v option.
do_version=false
# Exit status of this script.
exit_status=0

# Print debug log when debug is 1.
dbg() {
    if test "$debug" -eq "1" ; then
        echo "DBG:$*" >&2
    fi
}

# Print version of this script.
print_version() {
    echo "${version}"
}

on_error() {
    echo "$1" >&2
    exit_status=1
    do_help=true
}

__exit() {
    exit $exit_status
}

# Find top-level comments and print them.
#
# Examples:
#
# Top-level comment, threshold (-t) is 3:
#
# # 1st
# # 2nd
# # 3rd
#
# then outputs
#
# 1st
# 2nd
# 3rd
#
# Top-level function:
#
# # desc1
# # desc2
# func() {
# ...
#
# then outputs
#
# Function:func()
# desc1
# desc2
#
# Top-level variable:
#
# # desc1
# # desc2
# var=1
#
# then outputs
#
# Variable:var=1
# desc1
# desc2
display_docs() {
    # initialize a variable buf (array)
    readonly awkscript_init_buf='function init_buf(){split("",buf)}'
    # push element v to buf. l is for a local variable
    readonly awkscript_push='function push(v,l){l=length(buf);buf[l+1]=v}'
    # print all elements in buf. i is for a local variable
    readonly awkscript_print_buf='function print_buf(i){for(i in buf)print buf[i]}'
    # print newline
    readonly awkscript_nl='function nl(){printf("\n")}'

    readonly awkscript_defun="${awkscript_init_buf}${awkscript_push}${awkscript_print_buf}${awkscript_nl}"

    # prepare buf
    readonly awkscript_begin='BEGIN{init_buf()}'
    # pick up comment
    readonly awkscript_append='/^#/{x=$0;sub(/^#+ |#/,"",x);push(x)}'
    # write debug log
    readonly awkscript_debug_print='debug{printf("DBG[read][line=%d]:%s\n",NR,$0);printf("DBG[buf][line=%d][len=%d]:",NR,length(buf));for(i in buf)printf("[%s]",buf[i]);nl()}'
    # print function comment and clear buf
    readonly awkscript_print_function='/^[^#]/&&/\(\)/&&length(buf)>0{if(needfunc){match($0,/[^)]+\)/);print("Function:"substr($0,RSTART,RLENGTH));print_buf();nl()}init_buf()}'
    # print variable comment and clear buf
    readonly awkscript_print_variable='/^[^#]/&&/=/&&length(buf)>0{if(needvar){print("Variable:"$0);print_buf();nl()}init_buf()}'
    # print top level comment and clear buf
    readonly awkscript_print_toplevel='/^[^#]|^$/{if(length(buf)>=t){print_buf();nl()}init_buf()}'

    readonly awkscript_prog="${awkscript_begin}${awkscript_append}${awkscript_debug_print}${awkscript_print_function}${awkscript_print_variable}${awkscript_print_toplevel}"

    readonly awkscript="${awkscript_defun}${awkscript_prog}"
    dbg "$awkscript"

    $AWK -v t="$toplevel" -v needfunc="$needfunc" -v needvar="$needvar" -v debug="$debug" "$awkscript"
}

# Print usage of this script.
print_usage() {
    display_docs < "$0"
}

# Return status 1 if given argument $1 is a natural integer.
is_natural() {
    echo "$1" | $GREP --quiet --extended-regexp "^[0-9]+$"
}

while getopts ":hvrft:d" opts ; do
    case "$opts" in
        h)
            do_help=true
            ;;
        v)
            do_version=true
            ;;
        f)
            needfunc=1
            ;;
        r)
            needvar=1
            ;;
        t)
            if is_natural "$OPTARG" ; then
                toplevel="$OPTARG"
            else
                on_error "Option -t argument ${OPTARG} is not a non-negative integer."
            fi
            ;;
        d)
            debug=1
            ;;
        :)
            on_error "Option -${OPTARG} requires an argument."
            ;;
        *)
            on_error "Option -${OPTARG} is unknown."
            ;;
    esac
done

# get positional arguments
shift $((OPTIND-1))
# File to display documentations.
# Empty means stdin.
readonly target_file="$1"

dbg_params() {
    dbg "Parameter:toplevel: ${toplevel}"
    dbg "Parameter:needfunc: ${needfunc}"
    dbg "Parameter:needvar: ${needvar}"
    dbg "Parameter:do_help: ${do_help}"
    dbg "Parameter:do_version: ${do_version}"
    dbg "Parameter:exit_status: ${exit_status}"
    dbg "Parameter:target_file: ${target_file}"
}

dbg_params

if "$do_help" ; then
    print_usage
    __exit
fi

if "$do_version" ; then
    print_version
    __exit
fi

if test -n "$target_file" ; then
    display_docs < "$target_file"
else
    display_docs
fi

__exit
