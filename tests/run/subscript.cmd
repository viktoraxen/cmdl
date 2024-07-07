<< Indexing
signal b
signal a <= b[0]

<< Range
signal a: 2, b: 4
a <= b[0:2]

<< Range with negative start
signal a: 2, b: 5
a <= b[-3:-1]

<< Range with negative stop
signal a: 3, b: 5
a <= b[1:-1]

<< Range start after stop (positive)
< until: evaluate
< fail: SpanInvalidRangeError
a <= b[1:0]

<< Range start after stop (negative)
< until: evaluate
< fail: SpanInvalidRangeError
a <= b[-1:-2]

<< Range with only start
signal a: 4, b: 6
a <= b[2:]

<< Range with only stop
signal a: 4, b: 6
a <= b[:-2]

<< Index in unary expression
signal a, b: 4
a <= not b[0]

<< Index in binary expression
signal a, b: 3, c: 6
a <= b[0] and c[0]

<< Index in component expression
component Xor(a) => c
end
signal a, b: 4
a <= Xor(b[0])

<< Range in component expression
signal a, b: 6
component Xor(a) => c
end
a <= Xor(b[1:2])

<< Index of component expression
signal a, b
component Xor(a) => c: 5
end
a <= Xor(b)[0]

<< Range of component expression
signal a: 2, b
component Xor(a) => c: 6
end
a <= Xor(b)[0:2]
