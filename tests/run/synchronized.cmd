<< DFlip
< q: bx
< clk <= 1
< q: b0
synchronized Dflip(clk, d) => q
    q <= d
end
signal clk, d <= 0, 0
signal q <= Dflip(clk, d)

<< Missing inputs
< until: parse
< fail: ParseError
synchronized Dflip(clk) => q
end

<< Missing outputs
< until: parse
< fail: ParseError
synchronized Dflip(clk, d) => 
end

<< Duplicate inputs
< fail: SignatureDuplicateSignalError
synchronized Dflip(clk, a, a) => q
end

<< Sync ID name conflict
< fail: SignatureDuplicateSignalError
synchronized Dflip(clk, a, clk) => q
end

<< Duplicate outputs
< fail: SignatureDuplicateSignalError
synchronized Dflip(clk, d) => q, q
end

<< Input/output naming collision
< fail: SignatureDuplicateSignalError
synchronized Dflip(clk, d) => d
end

<< Invalid identifier
< fail: SignatureInvalidIdentifierError
component xor(a, b) => c
end

<< Duplicate identifier
< fail: ScopeDuplicateSubscopeError
synchronized Dflip(clk, d) => q
end
synchronized Dflip(clk, d) => q
end

<< Code block
synchronized Dflip(clk, d) => e
    signal b
    e <= d
end

<< Inputs with width
synchronized DFlip(clk, a: 2, b: 5) => c
end

<< Inputs with zero width
< until: evaluate
< fail: SignatureInputInvalidWidthError
synchronized DFlip(clk, a: 2, b: 0) => c
end

<< Inputs with negative width
< until: evaluate
< fail: SignatureInputInvalidWidthError
synchronized DFlip(clk, a: 2, b: -1) => c
end

<< Outputs with width
synchronized DFlip(clk, a, b) => c: 4, d:6
end

<< Outputs with zero width
< until: evaluate
< fail: SignatureOutputInvalidWidthError
synchronized DFlip(clk, a, b) => c: 4, d: 0
end

<< Outputs with negative width
< until: evaluate
< fail: SignatureOutputInvalidWidthError
synchronized DFlip(clk, a, b) => c: 4, d: -1
end

<< Inputs with width
< a: 2: 2
< c: bxx
< clk <= 1
< c: 2: 2
synchronized DFlip(clk, a: 2, b: 5) => c: 2
    c <= a
end
signal clk, a: 2, b: 5, c: 2
clk <= 0
a <= 2: 2
c <= DFlip(clk, a, b)
