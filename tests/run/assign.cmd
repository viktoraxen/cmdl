<< Single assign
signal a <= b

<< Two assignees, two expressions
signal a, b <= c, d

<< Many assignees, many expressions
signal a, b, c, d, e, f, g <= h, i, j, k, l, m, n

<< Invalid number of expressions
< fail: AssignmentNumberMismatchError
signal a, b <= c

<< Incompatible width (Input declared before)
< fail: AssignmentWidthMismatchError
signal c: 3
signal a: 2 <= c

<< Incompatible width (Input declared after)
< fail: AssignmentWidthMismatchError
< skip
signal a: 2 <= c
signal c: 3

