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
signal a, b, c, d
a, b <= c, d

<< Two recievers, two values (On declare)
signal c, d
signal a, b <= c, d

<< Two receivers, two values (Late declare)
a, b <= c, d
signal a, b, c, d

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
signal a, b, c
a <= b, c

<< More values (On declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
signal b, c
signal a <= b, c

<< More values (Late declare)
< until: evaluate
< fail: AssignmentNumberMismatchError
a <= b, c
signal a, b, c

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
