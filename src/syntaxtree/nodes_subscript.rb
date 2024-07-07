# frozen_string_literal: true

require_relative 'nodes_core'
require_relative '../types/subscript'
require_relative '../types/reference'

class SpanNode < ASTNode
    def start_node
        @children[0]
    end

    def end_node
        @children[1]
    end

    def evaluate(*)
        debug_log

        start_index = start_node&.evaluate
        debug_log 'Start Index:', start_index

        end_index = end_node&.evaluate
        debug_log 'End Index:', end_index

        assert_valid_span(start_index, end_index)

        Subscript.new(start_index, end_index)
    end
end

class IndexNode < ASTNode
    def start_node
        @children[0]
    end

    def evaluate(*)
        debug_log

        index = start_node.evaluate
        debug_log 'Index:', index

        Subscript.new(index, index + 1)
    end
end
