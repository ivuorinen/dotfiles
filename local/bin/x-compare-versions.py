#!/usr/bin/env python
"""
Version Comparison tool for the CLI.

Adapted from script found in anishathalye's dotfiles.
https://github.com/anishathalye/dotfiles/blob/master/bin/vercmp
"""

import operator
import sys

from packaging import version

str_to_operator = {
    "==": operator.eq,
    "!=": operator.ne,
    "<": operator.lt,
    "<=": operator.le,
    ">": operator.gt,
    ">=": operator.ge,
}


def vercmp(expr):
    """Version Comparison function."""
    words = expr.split()
    comparisons = [words[i: i + 3] for i in range(0, len(words) - 2, 2)]
    for left, op_str, right in comparisons:
        compare_op = str_to_operator[op_str]
        if not compare_op(version.parse(left), version.parse(right)):
            return False
    return True


def main():
    """Triggers version comparison if line is provided."""
    for line in sys.stdin:
        if not vercmp(line):
            sys.exit(1)
    sys.exit(0)


def test():
    """Basic functionality tests."""
    assert not vercmp("1.9 >= 2.4")
    assert vercmp("2.4 >= 2.4")
    assert vercmp("2.5 >= 2.4")
    assert vercmp("3 >= 2.999")
    assert vercmp("2.9 < 2.9a")
    assert vercmp("2.9a >= 2.8")


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "test":
        test()
    else:
        main()
