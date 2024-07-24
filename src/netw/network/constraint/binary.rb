require_relative 'core'

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
