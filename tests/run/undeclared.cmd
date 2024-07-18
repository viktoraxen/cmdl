<< Undeclared signal used
< fail: UndeclaredSignalError
signal c <= a

<< Undeclared assignment receiver
< fail: UndeclaredSignalError
signal a
c <= a

<< Undeclared signal used in unary expression
< fail: UndeclaredSignalError
signal c <= not a

<< Undeclared signal used in binary expression
< fail: UndeclaredSignalError
signal b
signal c <= a and b

<< Undeclared signal used as component input
< fail: UndeclaredSignalError
signal c <= Xor(a)
component Xor(a) => c
    c <= 1
end

<< Undeclared signal used in subscript
< fail: UndeclaredSignalError
signal c <= a.5
