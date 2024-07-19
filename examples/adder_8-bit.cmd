signal a: 8, b: 8, k: 1 <= 0: 8, 0: 8, 0
signal result: 8, c <= Adder(a, b, k)
signal res_m: 9 <= c ^ result

component Adder(a: 8, b: 8, k) => s: 8, c
    signal d: 7
    signal h: 8

    h.0 <= Xor(b.0, k)
    h.1 <= Xor(b.1, k)
    h.2 <= Xor(b.2, k)
    h.3 <= Xor(b.3, k)
    h.4 <= Xor(b.4, k)
    h.5 <= Xor(b.5, k)
    h.6 <= Xor(b.6, k)
    h.7 <= Xor(b.7, k)

    s.0, d.0 <= OneBitAdder(a.0, h.0, k)
    s.1, d.1 <= OneBitAdder(a.1, h.1, d.0)
    s.2, d.2 <= OneBitAdder(a.2, h.2, d.1)
    s.3, d.3 <= OneBitAdder(a.3, h.3, d.2)
    s.4, d.4 <= OneBitAdder(a.4, h.4, d.3)
    s.5, d.5 <= OneBitAdder(a.5, h.5, d.4)
    s.6, d.6 <= OneBitAdder(a.6, h.6, d.5)
    s.7, c   <= OneBitAdder(a.7, h.7, d.6)

    component OneBitAdder(a, b, cin) => s, cout
        signal z <= Xor(a, b)

        s    <= Xor(z, cin)
        cout <= (z and cin) or (a and b)
    end

    component Xor(a, b) => x
        x <= a and not b or not a and b
    end
end
