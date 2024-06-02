# frozen_string_literal: true

require_relative 'nodes_core'

class ConstantNode < LeafNode
end

class IdentifierNode < LeafNode
end

class NumberNode < LeafNode
    def evaluate(*)
        debug_log

        @value.to_i
    end
end
