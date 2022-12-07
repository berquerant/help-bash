#!/bin/bash

# test.sh runs unit tests.

set -e

readonly HELP_BASH="./help-bash.sh"
readonly FIND="${FIND:-find}"
readonly CUT="${CUT:-cut}"

readonly goldend="testdata/golden"

iterate_golden() {
    $FIND $goldend -type f
}
testcase2opts() {
    echo "$1" | $CUT -d "." -f 2
}

# Check -h
iterate_golden | while read testcase ; do
    opts="-h$(testcase2opts $testcase)"
    cmd="${HELP_BASH} ${opts}"
    echo "Check ${cmd} with ${testcase}..."
    diff "$testcase" <($cmd)
done

# Check path
iterate_golden | while read testcase ; do
    opts="$(testcase2opts $testcase)"
    if test -n "$opts" ; then
        opts="-${opts}"
    fi
    cmd="${HELP_BASH} ${opts} ${HELP_BASH}"
    echo "Check ${cmd} with ${testcase}..."
    diff "$testcase" <($cmd)
done

# Check stdin
iterate_golden | while read testcase ; do
    opts="$(testcase2opts $testcase)"
    if test -n "$opts" ; then
        opts="-${opts}"
    fi
    cmd="${HELP_BASH} ${opts}"
    echo "Check ${cmd} < ${HELP_BASH} with ${testcase}..."
    diff "$testcase" <($cmd < $HELP_BASH)
done
