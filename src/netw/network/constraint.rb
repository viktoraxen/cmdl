# frozen_string_literal: true

# !/usr/bin/env ruby

class Constraint
    attr_reader :name, :outputs, :inputs

    def initialize(name, inputs, output)
        @name = name
        @inputs = inputs
        @inputs.each { |input| input.add_connection(self) }
        @output = output
        @output.add_constraint(self)

        @type = 'constraint'

        new_value
    end

    def new_value
        unless determined?
            @output.value = '<nil>'
            return
        end

        assert_valid_gate_operation(@operation)

        new_value = @operation.call

        return if new_value == @output.value

        @output.value = new_value
    end

    def ==(other)
        type_s == other.type_s and @inputs == other.inputs and @output == other.output
    end

    def determined?
        @inputs.all? { |input| !input.value.nil? }
    end

    def to_s
        "#{type_s}: #{@inputs.map(&:name).join(', ')} -> #{@output.name}"
    end

    def type_s
        @type
    end

    def expression
        raise NotImplementedError
    end
end

class BinaryConstraint < Constraint
    def initialize(name, input1, input2, output)
        super(name, [input1, input2], output)

        @type = 'binary'
    end

    def expression
        "#{@inputs[0].name} #{type_s} #{@inputs[1].name}"
    end
end

class AndGate < BinaryConstraint
    def initialize(name, input1, input2, output)
        @operation = -> { @inputs[0].value and @inputs[1].value }

        super

        @type = 'and'
    end
end

class OrGate < BinaryConstraint
    def initialize(name, input1, input2, output)
        @operation = -> { @inputs[0].value or @inputs[1].value }

        super

        @type = 'or'
    end
end

class UnaryConstraint < Constraint
    def initialize(name, input, output)
        super(name, [input], output)
        @type = 'unary'
    end

    def expression
        "#{type_s} #{@inputs[0].name}"
    end
end

class NotGate < UnaryConstraint
    def initialize(name, input, output)
        @operation = -> { !@inputs[0].value }

        super

        @type = 'not'
    end
end

class AssignGate < UnaryConstraint
    def initialize(name, input, output)
        @operation = -> { @inputs[0].value }

        super

        @type = 'assign'
    end
end

class FanGate < Constraint
    def new_value
        @outputs.each_with_index do |output, i|
            # Skip if the value has not changed
            # Saves computation time by not propagting a false change in value
            input = @inputs[i % @inputs.length]
            next if input.value == output.value

            output.value = input.value
        end
    end

    def type_s
        'fan'
    end
end

class Wire
    attr_accessor :name
    attr_reader :value, :constraint, :connections

    def initialize(name, value = nil)
        @name = name
        @value = value

        # Constraints this wire is connected as input to
        @connections = []

        # Constraints acting on this wire
        @constraint = nil
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
        @value = value
        @connections.each(&:new_value)
    end

    def value_b
        value_map = {
            '<nil>' => 'x',
            nil     => 'x',
            true    => '1',
            false   => '0'
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
