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
