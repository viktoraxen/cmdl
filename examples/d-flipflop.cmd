component DFlipFlop(l, clk) => q, q_
    signal a, b, c, d, e, f

    a <= Nand(d, b)
    b <= Nand(clk, a)
    c <= Nand3(b, clk, d)
    d <= Nand(l, c)

    q <= Nand(b, q_)
    q_ <= Nand(c, q)

    component Nand(a, b) => x
        x <= not(a and b)
    end

    component Nand3(a, b, c) => x
        x <= not(a and b and c)
    end
end

signal l, clk, q, q_
q, q_ <= DFlipFlop(l, clk)
