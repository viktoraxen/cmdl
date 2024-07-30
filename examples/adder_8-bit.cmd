signal a: 8, b: 8, k: 1
k <= 0
signal result: 8, c <= Adder(a, b, k)
signal res_m: 9 <= c + result

component Adder(a: 8, b: 8, k) => s: 8, c
    signal d: 7
    signal h: 8

    h.0 <= b.0 xor k
    h.1 <= b.1 xor k
    h.2 <= b.2 xor k
    h.3 <= b.3 xor k
    h.4 <= b.4 xor k
    h.5 <= b.5 xor k
    h.6 <= b.6 xor k
    h.7 <= b.7 xor k

    s.0, d.0 <= OneBitAdder(a.0, h.0, k)
    s.1, d.1 <= OneBitAdder(a.1, h.1, d.0)
    s.2, d.2 <= OneBitAdder(a.2, h.2, d.1)
    s.3, d.3 <= OneBitAdder(a.3, h.3, d.2)
    s.4, d.4 <= OneBitAdder(a.4, h.4, d.3)
    s.5, d.5 <= OneBitAdder(a.5, h.5, d.4)
    s.6, d.6 <= OneBitAdder(a.6, h.6, d.5)
    s.7, c   <= OneBitAdder(a.7, h.7, d.6)

    component OneBitAdder(a, b, cin) => s, cout
        signal z <= a xor b

        s    <= z xor cin
        cout <= (z and cin) or (a and b)
    end
end
