<< Not (Early declare)
< a: b0
< b: b1
signal b <= 1
signal a
a <= not b

<< Not (On declare)
< a: b0
< b: b1
signal b <= 1
signal a <= not b

<< Not (Late declare)
< a: b0
< b: b1
signal a <= not b
signal b <= 1

<< Not shorthand (Early declare)
< a: b0
< b: b1
signal b <= 1
signal a
a <= !b

<< Not shorthand (On declare)
< a: b0
< b: b1
signal b <= 1
signal a <= !b

<< Not shorthand (Late declare)
< a: b0
< b: b1
signal a <= !b
signal b <= 1

<< Forbidden identifier not
< until: evaluate
< fail: ForbiddenIdentifierError
a <= b and not
