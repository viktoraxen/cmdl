# frozen_string_literal: true

require_relative '../../netw/network/network'

class Interface
    def initialize(network)
        @network = network
    end

    def state
        @network.state
    end

    def change(name, value)
        wire = @network.user_wire name
        @network._wire_set_value(wire, value)
    end
end
