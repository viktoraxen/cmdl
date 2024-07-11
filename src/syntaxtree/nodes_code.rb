# frozen_string_literal: true

require_relative '../error/cmdl_assert'
require_relative 'nodes_core'

class CodeBlockNode < ASTNode
    def statements_node
        @children[0]
    end

    def component_statement_nodes
        return [] if statements_node.nil?

        statements_node.children.select { |child| child.is_a?(ComponentNode) }
    end

    def declaration_statements_node
        return FlatListNode.new if statements_node.nil?

        FlatListNode.new(*statements_node.children.select { |child| child.is_a?(DeclarationNode) })
    end

    def assign_statements_node
        return FlatListNode.new if statements_node.nil?

        FlatListNode.new(*statements_node.children.select { |child| child.is_a?(AssignNode) })
    end

    def evaluate(scope, *)
        debug_log

        declaration_statements_node&.declare(scope)
        # assign_statements_node&.evaluate(scope)

        # component_statement_nodes.each do |child|
        #     child.evaluate(scope)
        # end
        statements_node&.evaluate(scope)

        scope
    end
end

class RootNode < ScopeNode
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
