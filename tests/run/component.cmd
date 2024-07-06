<< Unknown component
< fail: UnknownComponentError
a <= Xor(a, b)

<< Single without signature
< fail: ParseError
component Xor
end

<< Single with signature
component Xor(a, b) => c, d
end

<< Missing inputs
< fail: ParseError
component Xor() => c, d
end

<< Missing outputs
< fail: ParseError
component Xor(a, b) => 
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
< fail: DuplicateComponentIdentifierError
component Xor(a, b) => c
end
component Xor(a, b) => c
end

<< Code block
component Xor(a, b) => c
    signal d <= b
    c <= a and b
end
