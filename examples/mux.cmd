component Mux(a: 2, b: 2, r) => x: 2
    x.0 <= (a.0 and not r) or (b.0 and r)
    x.1 <= (a.1 and not r) or (b.1 and r)
end

signal a: 2 <= 3: 2
signal b: 2 <= 1: 2
signal r <= 1

signal c: 2 <= Mux(a, b, r)
