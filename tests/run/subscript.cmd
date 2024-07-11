<< Indexing
< a: b0
< b: b10
signal b: 2 <= 2: 2
signal a <= b.0

<< Indexing outside size
< fail: SubscriptIndexOutOfBoundsError
signal b: 4 <= 5: 4
signal a <= b.7

<< Negative indexing (-1)
< a: b1
< b: b1001
signal b: 4 <= 9: 4
signal a <= b.-1

<< Negative indexing (-2)
< a: b1
< b: b0101
signal b: 4 <= 5: 4
signal a <= b.-2

<< Negative indexing outside size
< fail: SubscriptIndexOutOfBoundsError
signal b: 4 <= 5: 4
signal a <= b.-7

<< Range
< a: b01
< b: b0101
signal a: 2
signal b: 4 <= 5: 4
a <= b.0:2

<< Range with negative start
< a: b01
< b: b00101
signal a: 2
signal b: 5 <= 5: 5
a <= b.-3:-1

<< Range with negative stop
< a: b010
< b: b00101
signal a: 3
signal b: 5 <= 5: 5
a <= b.1:-1

<< Range start after stop (positive)
< until: evaluate
< fail: SpanInvalidRangeError
a <= b.1:0

<< Range start after stop (negative)
< until: evaluate
< fail: SpanInvalidRangeError
a <= b.-1:-2

<< Right open range from 0
< a: b110110
< b: b110110
signal a: 6
signal b: 6 <= 54: 6
a <= b.0:

<< Right open range from 1
< a: b11011
< b: b110110
signal a: 5
signal b: 6 <= 54: 6
a <= b.1:

<< Left open range to -1
< a:  b10110
< b: b110110
signal a: 5
signal b: 6 <= 54: 6
a <= b.:-1

<< Index in unary expression
< a: b1
< b: b0000
signal a 
signal b: 4 <= 0: 4
a <= not b.0

<< Index in binary expression
< a: b1
< b: b111
< c: b001001
signal a
signal b: 3 <= 7: 3
signal c: 6 <= 9: 6
a <= b.0 and c.0

<< Index in component expression
< a: b1
< b: b0100
component Not(a) => c
    c <= not a
end
signal a 
signal b: 4 <= 4: 4
a <= Not(b.0)

<< Range in component expression
< a: b1
< b: b0100
component Not(a) => c
    c <= not a
end
signal a 
signal b: 4 <= 4: 4
a <= Not(b.1:2)

<< Index of component expression
< a: b1
< b: bx
component Xor(a) => c: 5
    c <= 3: 5
end
signal a, b
a <= Xor(b).0

<< Range of component expression
< a: b11
< b: bx
component Xor(a) => c: 5
    c <= 3: 5
end
signal a: 2, b
a <= Xor(b).:2

<< Expression subscript
signal a, b, c <= 1, 0, 1

<< Multiple signal index
< a: 1
< b: 0
< c: 1
signal d: 3 <= 5: 3
signal e: 6 <= 2: 6
signal f: 4 <= 13: 4
signal a, b, c <= (d, e, f).2

<< Multiple signal range
< a: b10
< b: b01
< c: b10
signal d: 3 <= 5: 3
signal e: 6 <= 2: 6
signal f: 4 <= 13: 4
signal a: 2, b: 2, c: 2 <= (d, e, f).1:3

<< Multiple expressions index
signal d: 3 <= 5: 3
signal e: 3 <= 2: 3
signal f: 3 <= 7: 3
signal a, b, c <= (d and e, f or e, d or e and not f).2

<< Multiple expressions range
signal d: 3 <= 5: 3
signal e: 3 <= 2: 3
signal f: 3 <= 7: 3
signal a: 2, b: 2, c: 2 <= (d and e, f or e, d or e and not f).0:2

<< Chained subscript
< skip
< a: b100111
< b: b01
# Chained subscripting does not work with the current implementation
# A fairly radical change would be needed to support this
signal a: 6 <= 39: 6
signal b: 4 <= a.:-1.:-1
