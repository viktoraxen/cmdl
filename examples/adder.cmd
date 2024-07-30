signal a: 4, b: 4, k: 1 <= 0: 4, 0: 4, 0
signal result: 4, c <= Adder(a, b, k)
signal res_m: 5 <= c + result

component Adder(a: 4, b: 4, k) => s: 4, c
    signal d: 3
    signal h: 4

    h.0 <= b.0 xor k
    h.1 <= b.1 xor k
    h.2 <= b.2 xor k
    h.3 <= b.3 xor k

    s.0, d.0 <= OneBitAdder(a.0, h.0, k)
    s.1, d.1 <= OneBitAdder(a.1, h.1, d.0)
    s.2, d.2 <= OneBitAdder(a.2, h.2, d.1)
    s.3, c   <= OneBitAdder(a.3, h.3, d.2)

    component OneBitAdder(a, b, cin) => s, cout
        signal z <= a xor b

        s    <= z xor cin
        cout <= (z and cin) or (a and b)
    end
end
