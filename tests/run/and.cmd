<< And (Early declare)
< a: b0
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b and c

<< And (On declare)
< a: b0
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b and c

<< And (Late declare)
< a: b0
< b: b1
< c: b0
a <= b and c
signal a 
signal b <= 1
signal c <= 0

<< And shorthand (Early declare)
< a: b0
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b & c

<< And shorthand (On declare)
< a: b0
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b & c

<< And shorthand (Late declare)
< a: b0
< b: b1
< c: b0
a <= b & c
signal a 
signal b <= 1
signal c <= 0

<< Forbidden identifier and
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and and
