require_relative 'core'

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
