component Merger(a, b, c, d) => x: 4
    x <= a ^ b ^ c ^ d
end

signal a, b, c, d <= 1, 1, 0, 1
signal x: 4 <= Merger(a, b, c, d)
