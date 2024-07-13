<< All primary gates
< a:    b0011
< b:    b0101
< and_: b0001
< or_:  b0111
< xor_: b0110
< nor_: b1000
< xnor_:b1001
< nand_:b1110
< nxor: b1001

signal a: 4 <= 3: 4
signal b: 4 <= 5: 4

signal and_:  4 <= a and b
signal or_:   4 <= a or b
signal xor_:  4 <= Xor(a, b)
signal nor_:  4 <= Nor(a, b)
signal xnor_: 4 <= Xnor(a, b)
signal nand_: 4 <= Nand(a, b)
signal nxor:  4 <= Xor::NotXor(a, b)

component Xor(a: 4, b: 4) => x: 4
    x <= not a and b or a and not b

    component NotXor(a: 4, b: 4) => x: 4
        x <= not Xor(a, b)
    end
end

component Nor(a: 4, b: 4) => x: 4
    x <= not a and not b
end

component Xnor(a: 4, b: 4) => x: 4
    x <= not Xor(a, b)
end

component Nand(a: 4, b: 4) => x: 4
    x <= not (a and b)
end

<< Four-bit adder
< s: 30: 5

signal s: 5 <= Adder(15: 4, 15: 4)

component Adder(a: 4, b: 4) => s: 5
    signal c: 3

    s.3, s.4 <= FullAdder(b.3, a.3, c.2)
    s.2, c.2 <= FullAdder(b.2, a.2, c.1)
    s.1, c.1 <= FullAdder(b.1, a.1, c.0)
    s.0, c.0 <= FullAdder(b.0, a.0, 0)

    component FullAdder(a, b, cin) => s, cout
        signal z <= Xor(a, b)

        s    <= Xor(z, cin)
        cout <= (z and cin) or (a and b)

        component Xor(a, b) => x
            x <= a and not b or not a and b
        end
    end
end
