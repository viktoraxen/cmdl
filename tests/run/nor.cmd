<< Nor (Early declare)
< a: b0
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b nor c

<< Nor (On declare)
< a: b0
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b nor c

<< Nor (Late declare)
< a: b0
< b: b1
< c: b0
signal a <= b nor c
signal b <= 1
signal c <= 0

<< Nor shorthand (Early declare)
< a: b0
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b !| c

<< Nor shorthand (On declare)
< a: b0
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b !| c

<< Nor shorthand (Late declare)
< a: b0
< b: b1
< c: b0
signal a <= b !| c
signal b <= 1
signal c <= 0

<< Nor 00
< a: b1
signal a <= 0 !| 0

<< Nor 01
< a: b0
signal a <= 0 !| 1

<< Nor 10
< a: b0
signal a <= 1 !| 0

<< Nor 11
< a: b0
signal a <= 1 !| 1

<< Forbidden identifier nor
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and nor
