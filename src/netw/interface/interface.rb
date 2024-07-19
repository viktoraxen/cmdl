# frozen_string_literal: true

class Interface
    def initialize(network)
        @network = network
    end

    def change(name, value)
        wire = @network.user_wires[name]
        @network._wire_set_value(wire, value)
    end
end
