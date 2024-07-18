# Binary expression width mismatch

<< Binary expression width mismatch (Early declare)
< until: evaluate
< fail: ExpressionBinaryInputWidthMismatchError
signal a: 2, b: 3, c: 2
c <= a and b

<< Binary expression width mismatch (Late declare)
< until: evaluate
< fail: ExpressionBinaryInputWidthMismatchError
c <= a and b
signal a: 2, b: 3, c: 2

<< Merge width mismatch
< fail: AssignmentWidthMismatchError
signal a: 6
signal b: 3, c: 2 <= 3: 3, 2: 2
a <= b cat c

# Unary expression width mismatch

<< Unary expression assignment width mismatch (Early declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
signal a, b: 2
a <= not b

<< Unary expression assignment width mismatch (On declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
signal b: 2
signal a <= not b

<< Unary expression assignment width mismatch (Late declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
a <= not b
signal a, b: 2

# Binary expression assignment width mismatch

<< Binary expression assignment width mismatch (Early declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
signal a: 2, b: 2, c
c <= a and b

<< Binary expression assignment width mismatch (On declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
signal a: 2, b: 2
signal c <= a and b

<< Binary expression assignment width mismatch (Late declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
c <= a and b
signal a: 2, b: 2, c

<< Binary expression subscript width mismatch
< fail: ExpressionBinaryInputWidthMismatchError
signal a: 4, b: 4, c
c <= a.1:3 and b.0:3

<< Binary expression negative subscript width mismatch
< fail: ExpressionBinaryInputWidthMismatchError
signal a: 4, b: 4, c
c <= a.-3: and b.-2:-1

# Component input width mismatch (Wide input)

<< Component input width mismatch (Wide input) (Early declare)
< until: evaluate
< fail: ExpressionComponentInputWidthMismatchError
component Xor(a, b) => c
end
signal a: 2, b, c
c <= Xor(a, b)

<< Component input width mismatch (Wide input) (On delcare)
< until: evaluate
< fail: ExpressionComponentInputWidthMismatchError
component Xor(a, b) => c
end
signal a: 2, b
signal c <= Xor(a, b)

<< Component input width mismatch (Wide input) (Late declare)
< until: evaluate
< fail: ExpressionComponentInputWidthMismatchError
component Xor(a, b) => c
end
c <= Xor(a, b)
signal a: 2, b, c

# Component input width mismatch (Wide receiver)

<< Component input width mismatch (Wide receiver) (Early declare)
< until: evaluate
< fail: ExpressionComponentInputWidthMismatchError
component Xor(a: 3, b) => c
end
signal a: 2, b, c
c <= Xor(a, b)

<< Component input width mismatch (Wide receiver) (On declare)
< until: evaluate
< fail: ExpressionComponentInputWidthMismatchError
component Xor(a: 3, b) => c
end
signal a: 2, b
signal c <= Xor(a, b)

<< Component input width mismatch (Wide receiver) (Late declare)
< until: evaluate
< fail: ExpressionComponentInputWidthMismatchError
component Xor(a: 3, b) => c
end
c <= Xor(a, b)
signal a: 2, b, c

