component Mux(a, b, r) => x
    x <= (a and not r) or (b and r)
end

signal a <= 1
signal b <= 0

signal c <= Mux(a, b, 1)
