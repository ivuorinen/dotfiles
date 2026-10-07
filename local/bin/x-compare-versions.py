#!/usr/bin/env -S uv run --quiet --script
#
# /// script
# dependencies = ["packaging"]
# ///
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
    if len(words) < 3 or len(words) % 2 == 0:
        return False
    comparisons = [words[i : i + 3] for i in range(0, len(words) - 2, 2)]
    for left, op_str, right in comparisons:
        compare_op = str_to_operator[op_str]
        if not compare_op(version.parse(left), version.parse(right)):
            return False
    return True


def main():
    """Triggers version comparison if line is provided."""
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        if not vercmp(line):
            sys.exit(1)
    sys.exit(0)


def check(expr, expected):
    """Raise AssertionError unless vercmp(expr) is expected.

    A bare `assert` is stripped under `python -O`, which would turn the
    self-test into a silent pass, and Codacy's Bandit flags every one as
    B101 because it ignores the per-plugin skip in pyproject.toml.
    """
    if vercmp(expr) is not expected:
        raise AssertionError(f"vercmp({expr!r}) is not {expected}")


def test():
    """Basic functionality tests."""
    check("1.9 >= 2.4", False)
    check("2.4 >= 2.4", True)
    check("2.5 >= 2.4", True)
    check("3 >= 2.999", True)
    check("2.9a < 2.9", True)
    check("2.9a >= 2.8", True)

    # multiple comparisons in a single expression
    check("1.0 < 2.0 <= 2.0", True)
    check("1.0 > 2.0 < 3.0", False)

    # mixed major/minor version comparisons
    check("2 >= 1.5", True)
    check("1 < 1.0", False)

    # trailing token (even word count) is rejected, not silently dropped
    check("1.0 < 2.0 junk", False)

    # invalid operator should raise an error
    try:
        vercmp("1.0 <> 2.0")
    except KeyError:
        pass
    else:
        raise AssertionError("invalid operator did not raise")


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "test":
        test()
    else:
        main()
