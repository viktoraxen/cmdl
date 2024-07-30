synchronized DFlipFlop(clk, d) => q, q_
    q, q_ <= d, not d
end

signal d, clk <= 0, 0
signal q, q_ <= DFlipFlop(clk, d)
