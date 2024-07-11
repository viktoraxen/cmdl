# And

<< And (Early declare)
< a: b0
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b and c

<< And (On declare)
< a: b0
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b and c

<< And (Late declare)
< a: b0
< b: b1
< c: b0
a <= b and c
signal a 
signal b <= 1
signal c <= 0

# Or 

<< Or (Early declare)
< a: b1
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b or c

<< Or (On declare)
< a: b1
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b or c

<< Or (Late declare)
< a: b1
< b: b1
< c: b0
signal a <= b or c
signal b <= 1
signal c <= 0

# Not

<< Not (Early declare)
< a: b0
< b: b1
signal b <= 1
signal a
a <= not b

<< Not (On declare)
< a: b0
< b: b1
signal b <= 1
signal a <= not b

<< Not (Late declare)
< a: b0
< b: b1
signal a <= not b
signal b <= 1

# Large expression

<< Large expression
< a: bx
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
< a: 1
signal a <= 1

<< Constant in expression
< a: 0
< b: 1
signal b <= 1
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
< a: 1
< b: 0
< c: 1
component Xor(a, b) => c
    c <= not a and b or not b and a
end
signal a <= 1
signal b <= 0
signal c 
c <= Xor(a, b)

<< Component expression (On declare)
< a: 1
< b: 0
< c: 1
component Xor(a, b) => c
    c <= not a and b or not b and a
end
signal a <= 1
signal b <= 0
signal c <= Xor(a, b)

<< Component expression (Late declare)
< a: 1
< b: 0
< c: 1
component Xor(a, b) => c
    c <= not a and b or not b and a
end
signal a <= 1
signal b <= 0
c <= Xor(a, b)
signal c

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

<< Component in and expression
< a: b1
component Xor(a, b) => c
    c <= 1
end
signal a, b, c
a <= Xor(b, c) and 1

<< Component in or expression
< a: b1
component Xor(a, b) => c
    c <= 1
end
signal a, b, c
a <= Xor(b, c) or 0

<< Component in not expression
< a: b0
component Xor(a, b) => c
    c <= 1
end
signal a, b, c
a <= not Xor(b, c)

<< Component multiple outputs
< a: b1
< b: b0
component Xor(a, b) => c, d
    c <= 1
    d <= 0
end
signal a, b, c
a, b <= Xor(b, c)

<< Component multiple outputs subscripting
< a: b0
< b: b1
component Xor(a, b) => c: 3, d: 4
    c <= 5: 3
    d <= 7: 4
end
signal a, b, c
a, b <= Xor(b, c).1

<< Component subscript in expression
< a: b0
component Xor(a, b) => c: 3
    c <= 5: 3
end
signal a
a <= Xor(a, a).1 and 1

<< Expression as component input
< a: 1
< b: 0
< c: 0
component Xor(a) => x
    x <= a
end
signal a <= 1
signal b <= 0
signal c <= Xor(a and b)

<< Component as component input
< a: 1
< b: 0
< c: 0
component And(a, b) => x
    x <= a and b
end
signal a <= 1
signal b <= 0
signal c <= And(And(a, b), a)

<< Subscript as component input (Index)
< a: 1
< b: b0101
< c: 1
component And(a, b) => x
    x <= a and b
end
signal a <= 1
signal b: 4 <= 5: 4
signal c <= And(b.2, a)

<< Subscript as component input (Range)
< a: 1
< b: b0101
< c: 0
component And(a: 2, b) => x
    x <= a.0 and b
end
signal a <= 1
signal b: 4 <= 5: 4
signal c <= And(b.1:3, a)

<< Subscript as component input (Right closed range)
< a: 1
< b: b0101
< c: 1
component And(a: 3, b) => x
    x <= a.1 and b
end
signal a <= 1
signal b: 4 <= 5: 4
signal c <= And(b.1:, a)

<< Subscript as component input (Left closed range)
< a: 1
< b: b0101
< c: 0
component And(a: 2, b) => x
    x <= a.1 and b
end
signal a <= 1
signal b: 4 <= 5: 4
signal c <= And(b.:2, a)

<< Complex component expression
component Xor(a, b) => x
    x <= not a and b or not b and a
end
component Nand(a, b) => x
    x <= not (a and b)
end
signal a: 3 <= 5: 3
signal b <= 0
signal c: 2 <= 3: 2
signal d <= Nand(
    Xor(a.1, b) or Nand(c.-1, b or a.0), 
    a.2 or Xor(Nand(b, c.0), b))
