<< Cyclic graph
signal a, b, c
a <= b
b <= c
c <= a

<< Component duplicate input
< r: 4: 4
< s: 4: 4
signal d: 4 <= 4: 4
signal r: 4, s: 4 <= Com(d, d, 0)

component Com(a: 4, b: 4, k) => r: 4, s: 4
    s <= b
    r <= a
end

<< Component duplicate constant input
< r: 4: 4
< s: 4: 4
signal r: 4, s: 4 <= Com(4: 4, 4: 4, 0)

component Com(a: 4, b: 4, k) => r: 4, s: 4
    s <= b
    r <= a
end

<< DFlipFlop
< clk <= 1
< q: 0: 1
< q_: 1: 1
< d <= 1
< q: 0: 1
< q_: 1: 1
< clk <= 0
< q: 0: 1
< q_: 1: 1
< clk <= 1
< q: 1: 1
< q_: 0: 1
synchronized DFlip(clk, d) => q, q_
    q <= d
    q_ <= not q
end

signal clk,d  <= 0, 0
signal q, q_ <= DFlip(clk, d)
