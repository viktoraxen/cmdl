# Large expression

<< Large expression
< a: bx
signal b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
signal a <= b and c or d and e or f and g or h and i or j and k or l and m or n and o or p and q or r and s or t and u or v and w or x and y or z

<< Large expression with parenthesis
signal b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
signal a <= (b and c or (d and e or f) and not (g or not h) and (i or (j and k) or l and m) or n and o or p and q or r and s or t and u or not (v and w or x) and y or z)

<< Invalid expression
< until: parse
< fail: ParseError
a <= and and and not not and

# Constant

<< Constant
< a: 1
signal a <= 1

<< Constant in expression
< a: 0
< b: 1
signal b <= 1
signal a <= b and not 1 or 0
