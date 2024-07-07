# And

<< And (Early declare)
signal a, b, c
a <= b and c

<< And (On declare)
signal b, c
signal a <= b and c

<< And (Late declare)
a <= b and c
signal a, b, c

# Or 

<< Or (Early declare)
signal a, b, c
a <= b or c

<< Or (On declare)
signal b, c
signal a <= b or c

<< Or (Late declare)
a <= b or c
signal a, b, c

# Not

<< Not (Early declare)
signal a, b
a <= not b

<< Not (On declare)
signal b
signal a <= not b

<< Not (Late declare)
a <= not b
signal a, b

# Large expression

<< Large expression
signal b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
signal a <= b and c or d and e or f and g or h and i or j and k or l and m or n and o or p and q or r and s or t and u or v and w or x and y or z

<< Large expression with parenthesis
signal b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
signal a <= (b and c or (d and e or f) and not (g or not h) and (i or (j and k) or l and m) or n and o or p and q or r and s or t and u or not (v and w or x) and y or z)

# Forbidden

<< Forbidden identifier and
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and and

<< Forbidden identifier or
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and b or not or

<< Forbidden identifier not
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and not

<< Invalid expression
< until: parse
< fail: ParseError
a <= and and and not not and

# Constant

<< Constant
signal a <= 1

<< Constant in expression
signal b
signal a <= b and not 1 or 0

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

# Component expression

<< Component expression (Early declare)
component Xor(a, b) => c
end
signal a, b, c
c <= Xor(a, b)

<< Component expression (Late declare)
signal a, b, c
c <= Xor(a, b)
component Xor(a, b) => c
end

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

# Component input number mismatch

<< Component fewer inputs
< until: evaluate
< fail: ExpressionComponentInputNumberMismatchError
component Xor(a, b) => c
end
signal a, b, c
c <= Xor(a)

<< Component more inputs
< until: evaluate
< fail: ExpressionComponentInputNumberMismatchError
component Xor(a, b) => c
end
signal a, b, c
c <= Xor(a, b, c)
