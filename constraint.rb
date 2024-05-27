# frozen_string_literal: true

# !/usr/bin/env ruby

# ----------------------------------------------------------------------------
#  Unidirectional constraint network for logic gates
# ----------------------------------------------------------------------------

# This is a simple example of a constraint network that uses logic gates.
# There are three classes of gates: AndGate, OrGate, and NotGate.
# Connections between gates are modelled as the class Wire.

require 'logger'

module MyPrettyPrint
    # To make printouts of connector objects easier, we define the
    # inspect method so that it returns the value of to_s. This method
    # is used by Ruby when we display objects in irb. By defining this
    # method in a module, we can include it in several classes that are
    # not related by inheritance.

    def inspect
        self.to_s
    end
end

class Constraint
    include MyPrettyPrint

    attr_reader :output, :inputs

    def initialize(name, inputs, output)
        @name = name
        @inputs = inputs
        @inputs.each { |input| input.add_connection(self) }
        @output = output
        @output.add_constraint(self)
        new_value unless @inputs.any? { |input| input.value == '<nil>' }
    end

    def ==(other)
        type_s == other.type_s and @inputs == other.inputs and @output == other.output
    end

    def determined?
        @inputs.all? { |input| input.value != '<nil>' }
    end

    def to_s
        "#{type_s}: #{@inputs.map(&:name).join(', ')} -> #{@output.name}"
    end

    def type_s
        'constraint'
    end

    def expression
        raise NotImplementedError
    end
end

class BinaryConstraint < Constraint
    include MyPrettyPrint

    # def initialize(input1, input2, output)
    #     super([input1, input2], output)
    # end

    def type_s
        'binary'
    end

    def expression
        "#{@inputs[0].name} #{type_s} #{@inputs[1].name}"
    end
end

class AndGate < BinaryConstraint
    include MyPrettyPrint

    def new_value
        @output.value = determined? ? (@inputs[0].value and @inputs[1].value) : '<nil>'
    end

    def type_s
        'and'
    end
end

class OrGate < BinaryConstraint
    include MyPrettyPrint

    def new_value
        return if @inputs.any? { |input| input.value == '<nil>' }
        @output.value = (@inputs[0].value or @inputs[1].value)
    end

    def type_s
        'or'
    end
end

class UnaryConstraint < Constraint
    include MyPrettyPrint

    def type_s
        'unary'
    end

    def expression
        "#{type_s} #{@inputs[0].name}"
    end
end

class NotGate < UnaryConstraint
    include MyPrettyPrint

    def new_value
        return if @inputs.any? { |input| input.value == '<nil>' }
        @output.value = (!@inputs[0].value)
    end

    def type_s
        'not'
    end
end

class DirectGate < UnaryConstraint
    include MyPrettyPrint

    def new_value
        return if @inputs.any? { |input| input.value == '<nil>' }
        @output.value = @inputs[0].value
    end

    def type_s
        'direct'
    end
end

class Wire
    include MyPrettyPrint

    attr_accessor :name
    attr_reader :value, :constraint, :connections

    def initialize(name, value = '<nil>')
        @name = name
        @value = value
        # Constraints this wire is connected as input to
        @connections = []
        # Constraints acting on this wire
        @constraint = nil
        @logger = Logger.new(@stdout)
    end

    def ==(other)
        @name == other.name
    end

    def log_level=(level)
        @logger.level = level
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
        @connections.each { |c| c.new_value }
    end

    def to_s
        "<Wire>: #{@name}"
    end
end
