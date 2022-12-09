# help-bash.sh

```
❯ ./help-bash.sh -h
help-bash.sh displays the things like documentation comments in .sh file.

USAGE:
  help-bash.sh [OPTIONS] [PATH]


ARGS:
    <PATH>
        A file to display documentations.


OPTIONS:
    -f
        Displays top-level (outside of any statements) functions documentations.
    -r
        Displays top-level variables documentations.
    -h
        Prints help information.
    -t
        Threshold to determine whether to display the top-level comments.
        e.g. the value is 3 then displays 3 or more lines of top-level comments.
        Default is 3.


ENVIRONMENT VARIABLES:
    AWK
        awk command.
    GREP
        grep command.
    HELP_BASH_DEBUG
        If value is 1 then enables debug logs.



help-bash.sh ends here.
```

Above is equivalent to `./help-bash.sh ./help-bash.sh`.

Include variables and functions with comment of `help-bash.sh`:

```
❯ ./help-bash.sh -hfr
help-bash.sh displays the things like documentation comments in .sh file.

USAGE:
  help-bash.sh [OPTIONS] [PATH]


ARGS:
    <PATH>
        A file to display documentations.


OPTIONS:
    -f
        Displays top-level (outside of any statements) functions documentations.
    -r
        Displays top-level variables documentations.
    -h
        Prints help information.
    -t
        Threshold to determine whether to display the top-level comments.
        e.g. the value is 3 then displays 3 or more lines of top-level comments.
        Default is 3.


ENVIRONMENT VARIABLES:
    AWK
        awk command.
    GREP
        grep command.
    HELP_BASH_DEBUG
        If value is 1 then enables debug logs.

Variable:debug="${HELP_BASH_DEBUG:-0}"
For envvar HELP_BASH_DEBUG.

Variable:toplevel=3
For -t option.

Variable:needfunc=0
For -f option.

Variable:needvar=0
For -r option.

Variable:do_help=false
For -h option.

Variable:exit_status=0
Exit status of this script.

Function:dbg()
Print debug log when debug is 1.

Function:display_docs()
Find top-level comments and print them.

Examples:

Top-level comment, threshold (-t) is 3:

# 1st
# 2nd
# 3rd

then outputs

1st
2nd
3rd

Top-level function:

# desc1
# desc2
func() {
...

then outputs

Function:func()
desc1
desc2

Top-level variable:

# desc1
# desc2
var=1

then outputs

Variable:var=1
desc1
desc2

Function:print_usage()
Print usage of this script.

Function:is_natural()
Return status 1 if given argument $1 is a natural integer.

Variable:readonly target_file="$1"
File to display documentations.
Empty means stdin.



help-bash.sh ends here.
```

# Requirements

- GNU bash, 5.2.9(1)-release (aarch64-apple-darwin22.1.0)
- GNU Awk 5.2.0, API 3.2, (GNU MPFR 4.1.0-p13, GNU MP 6.2.1)
- grep (BSD grep, GNU compatible) 2.6.0-FreeBSD

# Development

- [Run unit tests](./run-test.sh)
- [Generate golden testdata](./generate-golden.sh)
