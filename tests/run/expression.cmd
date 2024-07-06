<< And
a <= b and c

<< Or 
a <= a or b

<< Not
a <= not b

<< Large expression
a <= b and c or d and e or f and g or h and i or j and k or l and m or n and o or p and q or r and s or t and u or v and w or x and y or z

<< Large expression with parenthesis
a <= (b and c or (d and e or f) and not (g or not h) and (i or (j and k) or l and m) or n and o or p and q or r and s or t and u or not (v and w or x) and y or z)

<< Forbidden identifier and
< fail: ForbiddenIdentifierError
a <= b and and

<< Forbidden identifier or
< fail: ForbiddenIdentifierError
a <= b and b or not or

<< Forbidden identifier not
< fail: ForbiddenIdentifierError
a <= b and not

<< Invalid expression
< fail: ParseError
a <= and and and not not and

<< Constant
a <= 1

<< Constant in expression
a <= b and not 1 or 0
