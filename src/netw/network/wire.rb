class Wire
    attr_accessor :name, :network
    attr_reader :value, :constraint, :connections

    def initialize(name, value = nil)
        @name = name
        @value = value

        # Constraints this wire is connected as input to
        @connections = []

        # Constraints acting on this wire
        @constraint = nil

        @network = nil
    end

    def ==(other)
        @name == other.name
    end

    def add_constraint(gate)
        @constraint = gate
    end

    def add_connection(gate)
        @connections << gate
    end

    def remove_connection(gate)
        @connections.delete_if { |c| c == gate }
    end

    def clear_constraints
        @constraint = []
    end

    def value=(value)
        return if value == @value

        queue = []

        set_value(value, queue)

        queue.shift.new_value(queue) until queue.empty?

        # @connections.each(&:new_value)
    end

    def set_value(value, queue)
        @value = value

        queue&.concat(@connections)

        @network.notify_new_value(self) unless @network.nil?
    end

    def value_b
        value_map = {
            nil   => 'x',
            true  => '1',
            false => '0'
        }

        value_map[@value]
    end

    def inspect
        to_s
    end

    def to_s
        "<Wire>: #{@name}"
    end
end
