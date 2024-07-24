synchronized Adder(clk, a: 4, b: 4, k) => s: 4, c
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

    component OneBitAdder(a_, b_, cin_) => s_, cout_
        signal z <= Xor(a_, b_)

        s_    <= Xor(z, cin_)
        cout_ <= (z and cin_) or (a_ and b_)
    end

    component Xor(a_, b_) => x_
        x_ <= a_ and not b_ or not a_ and b_
    end
end

signal clk <= 0
signal in: 4, out: 4, c

out, c <= Adder(clk, in, 1: 4, 0) 
in <= out

