<< Nand (Early declare)
< a: b1
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b nand c

<< Nand (On declare)
< a: b1
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b nand c

<< Nand (Late declare)
< a: b1
< b: b1
< c: b0
signal a <= b nand c
signal b <= 1
signal c <= 0

<< Nand shorthand (Early declare)
< a: b1
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b !& c

<< Nand shorthand (On declare)
< a: b1
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b !& c

<< Nand shorthand (Late declare)
< a: b1
< b: b1
< c: b0
signal a <= b !& c
signal b <= 1
signal c <= 0

<< Nand 00
< a: b1
signal a <= 0 !& 0

<< Nand 01
< a: b1
signal a <= 0 !& 1

<< Nand 10
< a: b1
signal a <= 1 !& 0

<< Nand 11
< a: b0
signal a <= 1 !& 1

<< Forbidden identifier nand
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and nand
