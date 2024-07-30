<< Compare (Early declare)
< a: 0
< b: 1
< c: 0
signal a
signal b <= 1
signal c <= 0
a <= b eq c

<< Compare (On declare)
< a: 0
< b: 1
< c: 0
signal b <= 1
signal c <= 0
signal a <= b eq c

<< Compare (Late declare)
< a: 0
< b: 1
< c: 0
signal a <= b eq c
signal b <= 1
signal c <= 0

<< Compare (Early declare)
< a: 0
< b: 1
< c: 0
signal a
signal b <= 1
signal c <= 0
a <= b = c

<< Compare (On declare)
< a: 0
< b: 1
< c: 0
signal b <= 1
signal c <= 0
signal a <= b = c

<< Compare (Late declare)
< a: 0
< b: 1
< c: 0
signal a <= b = c
signal b <= 1
signal c <= 0

<< Compare true equal
< a: 1
< b: 1
< c: 1
signal b, c <= 1, 1
signal a <= b eq c

<< Compare false equal
< a: 1
< b: 0
< c: 0
signal b, c <= 0, 0
signal a <= b eq c

<< Compare inequal
< a: 0
< b: 0
< c: 1
signal b, c <= 0, 1
signal a <= b eq c

<< Wide signals inequal
< a: 0
< b: 13: 6
< c: 25: 6
signal b: 6 <= 13: 6
signal c: 6 <= 25: 6
signal a <= b eq c

<< Wide signals equal
< a: 1
< b: b10001
< c: b10001
signal b: 5, c: 5 <= 17: 5, 17: 5
signal a <= b eq c

<< Multiple inequal
< a: 0
< f: 0
< b: b01111
< c: b10001
< d: b10001
< e: b10011
signal b: 5, c: 5 <= 15: 5, 17: 5
signal d: 5, e: 5 <= 17: 5, 19: 5
signal a, f <= (b, d) eq (c, e)

<< Multiple equal
< a: 1
< f: 1
< b: b10001
< c: b10001
< d: b10001
< e: b10001
signal b: 5, c: 5 <= 17: 5, 17: 5
signal d: 5, e: 5 <= 17: 5, 17: 5
signal a, f <= (b, d) eq (c, e)

<< Multiple mixed
< a: 0
< f: 1
< b: b10001
< c: b01101
< d: b10001
< e: b10001
signal b: 5, c: 5 <= 17: 5, 13: 5
signal d: 5, e: 5 <= 17: 5, 17: 5
signal a, f <= (b, d) eq (c, e)
