<< Same scope
< c: 1
component Xor(a, b) => c
    c <= a and b
end

signal a, b <= 1, 1
signal c <= Xor(a, b)

<< One level down
< c: 1
component Xor(a, b) => c
    c <= a and b

    component Nor(a, b) => d
        d <= not (a or b)
    end
end

signal a, b <= 0, 0
signal c <= Xor.Nor(a, b)

<< Five levels down
< c: 1
component Xor(a, b) => c
    c <= a and b
    component Nor(a, b) => d
        d <= not (a or b)
        component Bor(a, b) => d
            d <= not (a or b)
            component Mor(a, b) => d
                d <= not (a or b)
                component Zor(a, b) => d
                    d <= (a or b)
                end
            end
        end
    end
end

signal a, b <= 1, 0
signal c <= Xor.Nor.Bor.Mor.Zor(a, b)

<< One level up
component Xor(a, b) => c
    c <= a and b
    component Nor(a, b) => d
        d <= not (a or b)
        d <= Zor(a, b)
    end
    component Zor(a, b) => d
        d <= not (a or b)
    end
end

<< Two levels up
component Xor(a, b) => c
    c <= a and b
    component Nor(a, b) => d
        d <= not (a or b)
        d <= Zor(a, b)
    end
end
component Zor(a, b) => d
    d <= not (a or b)
end

<< Two levels up, three levels down
component Xor(a, b) => c
    c <= a and b
    component Nor(a, b) => d
        d <= not (a or b)
        d <= Zor.Mor.Wor.Por(a, b)
    end
end
component Zor(a, b) => d
    d <= not (a or b)
    component Mor(a, b) => d
        d <= not (a or b)
        component Wor(a, b) => d
            d <= not (a or b)
            component Por(a, b) => d
                d <= not (a or b)
            end
        end
    end
end

<< Two levels up, three levels down
component Xor(a, b) => c
    component Nor(a, b) => d
        d <= Zor.Mor.Wor.Por(a, b)
    end
    component Zor(a, b) => d
        component Mor(a, b) => d
            component Wor(a, b) => d
                d <= a or b
            end
        end
    end
end
component Zor(a, b) => d
    component Mor(a, b) => d
        component Wor(a, b) => d
            component Por(a, b) => d
                d <= not (a or b)
            end
        end
    end
end
