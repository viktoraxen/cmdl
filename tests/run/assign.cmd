<< Single assign (Early declare)
signal a, b
a <= b

<< Single assign (On declare)
signal b
signal a <= b

<< Single assign (Late declare)
a <= b
signal a, b

<< Two receivers, two values (Early declare)
< a: 1
< b: 0
signal a, b
a, b <= 1, 0

<< Two recievers, two values (On declare)
< a: 0
< b: 1
signal a, b <= 0, 1

<< Two receivers, two values (Late declare)
< a: 1
< b: 0
a, b <= 1, 0
signal a, b

<< Many receivers, many values (Early declare)
signal a, b, c, d, e, f, g, h, i, j, k, l, m, n
a, b, c, d, e, f, g <= h, i, j, k, l, m, n

<< Many receivers, many values (On declare)
signal h, i, j, k, l, m, n
signal a, b, c, d, e, f, g <= h, i, j, k, l, m, n

<< Many receivers, many values (Late declare)
a, b, c, d, e, f, g <= h, i, j, k, l, m, n
signal a, b, c, d, e, f, g, h, i, j, k, l, m, n

<< More values (Early declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
signal a
a <= 1, 0

<< More values (On declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
signal a <= 1, 0

<< More values (Late declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
a <= 0, 1
signal a

<< Fewer values (Early declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
signal a, b, c
a, b <= c

<< Fewer values (On declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
signal c
signal a, b <= c

<< Fewer values (Late declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
a, b <= c
signal a, b, c

<< Assignment of constant (Early declare)
< a: b10
signal a: 2 
a <= 2: 2

<< Assignment of constant (On declare)
< a: b10
signal a: 2 <= 2: 2

<< Assignment of constant (Late declare)
< a: b1000011
a <= 67: 7
signal a: 7

<< Incompatible width (Early declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
signal a: 2, c: 3
a <= c

<< Incompatible width (On declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
signal c: 3
signal a <= c

<< Incompatible width (Late declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
a <= c
signal a: 2, c: 3

<< Component output width mismatch (wide output) (Early declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
component Xor(a: 2, b) => c: 3
end
signal a: 2, b, c: 2
c <= Xor(a, b)

<< Component output width mismatch (wide output) (On declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
component Xor(a: 2, b) => c: 3
end
signal a: 2, b
signal c <= Xor(a, b)

<< Component output width mismatch (wide output) (Late declare)
< until: evaluate
< fail: AssignmentWidthMismatchError
component Xor(a: 2, b) => c: 3
end
c <= Xor(a, b)
signal a: 2, b, c

<< Component fewer receivers (Early declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
component Xor(a: 2, b) => c, d
end
signal a: 2, b, c
c <= Xor(a, b)

<< Component fewer receivers (On declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
component Xor(a: 2, b) => c, d
end
signal a: 2, b
signal c <= Xor(a, b)

<< Component fewer receivers (Late declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
component Xor(a: 2, b) => c, d
end
c <= Xor(a, b)
signal a: 2, b, c

<< Component more receivers (Early declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
component Xor(a: 2, b) => c
end
signal a: 2, b, c, d
c, d <= Xor(a, b)

<< Component more receivers (On declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
component Xor(a: 2, b) => c
end
signal a: 2, b
signal c, d <= Xor(a, b)

<< Component more receivers (Late declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
component Xor(a: 2, b) => c
end
c, d <= Xor(a, b)
signal a: 2, b, c, d

<< Multiple expression
< a: 0
< b: 1
< c: 1
signal a, b, c
a, b, c <= 1 and 0, a or c, 0 or 1

<< Multiple component expressions
< a: 1
< b: 1
< c: 1
component Xor(a, b) => c
    c <= a and b
end
signal a, b, c
a, b, c <= Xor(b, c), c, 1
