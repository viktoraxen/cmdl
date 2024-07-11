signal result: 4, c <= Adder(0: 4, 15: 4, 1)

component Adder(a: 4, b: 4, k) => s: 4, c
    signal d: 3
    signal h: 4

    h.0 <= Xor(b.0, k)
    h.1 <= Xor(b.1, k)
    h.2 <= Xor(b.2, k)
    h.3 <= Xor(b.3, k)

    s.0, d.0 <= OneBitAdder(a.0, h.0, k)
    s.1, d.1 <= OneBitAdder(a.1, h.1, d.0)
    s.2, d.2 <= OneBitAdder(a.2, h.2, d.1)
    s.3, c   <= OneBitAdder(a.3, h.3, d.2)

    component OneBitAdder(a, b, cin) => s, cout
        signal z <= Xor(a, b)

        s    <= Xor(z, cin)
        cout <= (z and cin) or (a and b)
    end

    component Xor(a, b) => x
        x <= a and not b or not a and b
    end
end
