<< Xnor (Early declare)
< a: b0
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b xnor c

<< Xnor (On declare)
< a: b0
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b xnor c

<< Xnor (Late declare)
< a: b0
< b: b1
< c: b0
signal a <= b xnor c
signal b <= 1
signal c <= 0

<< Xnor shorthand (Early declare)
< a: b0
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b ~ c

<< Xnor shorthand (On declare)
< a: b0
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b ~ c

<< Xnor shorthand (Late declare)
< a: b0
< b: b1
< c: b0
signal a <= b ~ c
signal b <= 1
signal c <= 0

<< Xnor 00
< a: b1
signal a <= 0 ~ 0

<< Xnor 01
< a: b0
signal a <= 0 ~ 1

<< Xnor 10
< a: b0
signal a <= 1 ~ 0

<< Xnor 11
< a: b1
signal a <= 1 ~ 1

<< Forbidden identifier xnor
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and xnor
