<< Or (Early declare)
< a: b1
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b or c

<< Or (On declare)
< a: b1
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b or c

<< Or (Late declare)
< a: b1
< b: b1
< c: b0
signal a <= b or c
signal b <= 1
signal c <= 0

<< Or shorthand (Early declare)
< a: b1
< b: b1
< c: b0
signal a
signal b <= 1
signal c <= 0
a <= b | c

<< Or shorthand (On declare)
< a: b1
< b: b1
< c: b0
signal b <= 1
signal c <= 0
signal a <= b | c

<< Or shorthand (Late declare)
< a: b1
< b: b1
< c: b0
signal a <= b | c
signal b <= 1
signal c <= 0

<< Forbidden identifier or
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and or
