component DFlipFlop(d, clk) => q, q_
    signal a, b

    a <= not(d and clk)
    b <= not(not d and clk)

    q <= not(a and q_)
    q_ <= not(b and q)
end

signal d, clk
clk <= 0
signal q, q_ <= DFlipFlop(d, clk)
