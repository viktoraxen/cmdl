component SRFlip(s, r) => q, q_
    q, q_ <= not(s and q_), not(r and q)
end

component GatedSRFlip(s, r, en) => q, q_
    q, q_ <= SRFlip(not(s and en), not(r and en))
end

# Oscillates between set and reset when clk goes HIGH and both j and k are HIGH
component JKFlip(j, k, clk) => q, q_
    signal a, b

    a <= not(j and clk and q_)
    b <= not(k and clk and q)

    q, q_ <= SRFlip(a, b)
end

component MSJKFlip(j, k, clk) => q, q_
    signal a, b
    a, b  <= JKFlip(j and q_, k and q, clk)
    q, q_ <= JKFlip(a, b, not clk)
end

signal j, k, clk <= 0, 1, 0
signal q, q_ <= MSJKFlip(j, k, clk)
