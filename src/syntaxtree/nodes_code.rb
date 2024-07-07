# frozen_string_literal: true

require_relative '../core/cmdl_assert'
require_relative 'nodes_core'

class CodeBlockNode < ASTNode
    def statements_node
        @children[0]
    end

    def component_statements
        return [] if statements_node.nil?

        statements_node.children.select { |child| child.is_a?(ComponentNode) }
    end

    def evaluate(scope, *)
        debug_log

        statements_node&.evaluate(scope)

        scope
    end
end

class RootNode < ASTNode
    def evaluate(scope, *)
        debug_log

        @children.each do |child|
            Log.debug ''
            child.evaluate(scope)
        end

        scope
    end
end

class StatementListNode < FlatListNode
end
