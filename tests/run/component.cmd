<< Unknown component
< fail: UnknownComponentError
a <= Xor(a, b)

<< Single without signature
< until: parse
< fail: ParseError
component Xor
end

<< Single with signature
component Xor(a, b) => c, d
end

<< Missing inputs
< until: parse
< fail: ParseError
component Xor() => c, d
end

<< Missing outputs
< until: parse
< fail: ParseError
component Xor(a, b) => 
end

<< Duplicate inputs
< fail: ComponentDuplicateSignatureSignalError
component Xor(a, a) => c
end

<< Duplicate outputs
< fail: ComponentDuplicateSignatureSignalError
component Xor(a, c) => d, d
end

<< Inputs/outputs naming collision
< fail: ComponentDuplicateSignatureSignalError
component Xor(a, b) => a
end

<< Nestling
component Xor(a, b) => c
    component cor(a, b) => c
        component nor(a, b) => c
        end
    end
    component bor(a, b) => c
        component Xor(a, b) => c
        end
        component vor(a, b) => c
            component Xor(a, b) => c
            end
        end
    end
    component sor(a, b) => c
    end
end

<< Duplicate identifier
< until: evaluate
< fail: ScopeDuplicateSubscopeError
component Xor(a, b) => c
end
component Xor(a, b) => c
end

<< Code block
component Xor(a, b) => c
    signal d <= b
    c <= a and b
end

<< Inputs with width
component Xor(a: 2, b: 5) => c
end

<< Inputs with zero width
< until: evaluate
< fail: ComponentInputInvalidWidthError
component Xor(a: 2, b: 0) => c
end

<< Inputs with negative width
< until: evaluate
< fail: ComponentInputInvalidWidthError
component Xor(a: 2, b: -1) => c
end

<< Outputs with width
component Xor(a, b) => c: 4, d:6
end

<< Outputs with zero width
< until: evaluate
< fail: ComponentOutputInvalidWidthError
component Xor(a, b) => c: 4, d: 0
end

<< Outputs with negative width
< until: evaluate
< fail: ComponentOutputInvalidWidthError
component Xor(a, b) => c: 4, d: -1
end

