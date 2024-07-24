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
