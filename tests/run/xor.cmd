<< Xor (Early declare)
< a: b1
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b xor c

<< Xor (On declare)
< a: b1
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b xor c

<< Xor (Late declare)
< a: b1
< b: b1
< c: b0
signal a <= b xor c
signal b <= 1
signal c <= 0

<< Xor shorthand (Early declare)
< a: b1
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b ^ c

<< Xor shorthand (On declare)
< a: b1
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b ^ c

<< Xor shorthand (Late declare)
< a: b1
< b: b1
< c: b0
signal a <= b ^ c
signal b <= 1
signal c <= 0

<< Xor 00
< a: b0
signal a <= 0 ^ 0

<< Xor 01
< a: b1
signal a <= 0 ^ 1

<< Xor 10
< a: b1
signal a <= 1 ^ 0

<< Xor 11
< a: b0
signal a <= 1 ^ 1

<< Forbidden identifier xor
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and xor
