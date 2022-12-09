#!/bin/bash

# test.sh runs unit tests.
# Testcases are defined in testdata/golden/
# $1 is a command to be tested, default is ./help-bash.sh

set -e

readonly HELP_BASH_SH="./help-bash.sh"
readonly HELP_BASH="${1:-${HELP_BASH_SH}}"
readonly FIND="${FIND:-find}"
readonly CUT="${CUT:-cut}"

readonly goldend="testdata/golden"

is_bash() {
    test "${HELP_BASH}" == "${HELP_BASH_SH}"
}
iterate_golden() {
    $FIND $goldend -type f
}
testcase2opts() {
    echo "$1" | $CUT -d "." -f 2
}

# Check -h option.
test_h() {
    if ! is_bash ; then
        echo "Skip -h test" >&2
        return
    fi
    iterate_golden | while read testcase ; do
        opts="-h$(testcase2opts $testcase)"
        cmd="${HELP_BASH} ${opts}"
        echo "Check ${cmd} with ${testcase}..."
        diff "$testcase" <($cmd)
    done
}

test_h

# Check path
iterate_golden | while read testcase ; do
    opts="$(testcase2opts $testcase)"
    if test -n "$opts" ; then
        opts="-${opts}"
    fi
    cmd="${HELP_BASH} ${opts} ${HELP_BASH_SH}"
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
    echo "Check ${cmd} < ${HELP_BASH_SH} with ${testcase}..."
    diff "$testcase" <($cmd < $HELP_BASH_SH)
done
