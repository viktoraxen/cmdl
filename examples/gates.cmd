signal a: 4 <= 3: 4
signal b: 4 <= 5: 4

signal and_: 4 <= a and b
signal or_:  4 <= a or b
signal not_: 4 <= not a
signal xor:  4 <= Xor(a, b)
signal nor:  4 <= Nor(a, b)
signal xnor: 4 <= Xnor(a, b)
signal nand: 4 <= Nand(a, b)
signal nxor: 4 <= Xor::NotXor(a, b)

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
