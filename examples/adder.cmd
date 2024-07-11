signal sum: 5 <= Adder(15: 4, 15: 4)

# Component for adding two 4-bit numbers
component Adder(a: 4, b: 4) => s: 5
    signal c: 3 # Intermediate carry signals

    s.3, s.4 <= FullAdder(b.3, a.3, c.2)
    s.2, c.2 <= FullAdder(b.2, a.2, c.1)
    s.1, c.1 <= FullAdder(b.1, a.1, c.0)
    s.0, c.0 <= FullAdder(b.0, a.0, 0)

    # Helper component for adding two 1-bit numbers
    component FullAdder(a, b, cin) => s, cout
        signal z <= Xor(a, b)

        s    <= Xor(z, cin)
        cout <= (z and cin) or (a and b)

        # Helper component performing exclusive or operation
        component Xor(a, b) => x
            x <= a and not b or not a and b
        end
    end
end
