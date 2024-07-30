# Merge

<< Merge (Early declare)
< a: b10
< b: b1
< c: b0
signal a: 2
signal b <= 1
signal c <= 0
a <= b cat c

<< Merge (On declare)
< a: b10
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a: 2 <= b cat c

<< Merge (Late declare)
< a: b10
< b: b1
< c: b0
signal a: 2 <= b cat c
signal b <= 1
signal c <= 0

<< Merge shorthand (Early declare)
< a: b10
< b: b1
< c: b0
signal a: 2
signal b <= 1
signal c <= 0
a <= b + c

<< Merge shorthand (On declare)
< a: b10
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a: 2 <= b + c

<< Merge shorthand (Late declare)
< a: b10
< b: b1
< c: b0
signal a: 2 <= b + c
signal b <= 1
signal c <= 0

<< Different widths
< a: b01110
< b: b011
< c: b10
signal a: 5
signal b: 3, c: 2 <= 3: 3, 2: 2
a <= b cat c

<< Invalid identifiere merge
< fail: ForbiddenIdentifierError
a <= b cat and
