# frozen_string_literal: true

require_relative '../core/cmdl_assert'

require_relative 'nodes_core'

class BinaryNumberNode < LeafNode
    def evaluate(*)
        debug_log

        @value.to_i(2)
    end
end

class ConstantNode < ASTNode
    def number_node
        @children[0]
    end

    def evaluate(*)
        debug_log

        number = number_node.evaluate
        debug_log 'Number:', number

        Constant.new(number)
    end
end

class ConstantSubscriptNode < ASTNode
    def number_node
        @children[0]
    end

    def width_node
        @children[1]
    end

    def evaluate(*)
        debug_log

        number = number_node.evaluate
        debug_log 'Number:', number

        width = width_node.evaluate
        debug_log 'Width:', width

        Constant.new(number, width)
    end
end

class IdentifierNode < LeafNode
    def append_id(str)
        @value += str
    end

    def evaluate(*)
        debug_log

        assert_valid_identifier(@value)

        @value
    end
end


class NumberNode < LeafNode
    def evaluate(*)
        debug_log

        @value.to_i
    end
end

class StringNode < LeafNode
end
