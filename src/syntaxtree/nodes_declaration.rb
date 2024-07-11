# frozen_string_literal: true

require_relative '../types/declarator'

require_relative 'nodes_core'

class DeclarationNode < ASTNode
    def declarators_node
        @children[0]
    end

    def expressions_node
        @children[1]
    end
    
    def declare(scope)
        debug_log

        declarators = declarators_node.evaluate(scope)
        debug_log 'Declarators:', declarators

        assert_valid_declaration(scope, declarators)

        # Declare wires
        @declarator_refs = declarators.map do |declarator|
            scope.template.declare(declarator)
        end

        debug_log 'References:', @declarator_refs

        @declarator_refs
    end

    def evaluate(scope, *)
        return if expressions_node.nil?

        value_refs = expressions_node.evaluate(scope)
        debug_log 'Values:', value_refs

        assert_valid_assignment(scope, @declarator_refs, value_refs)

        # Assign wires
        scope.template.assign(@declarator_refs, value_refs)
    end
end

class DeclaratorListNode < ListNode
end

class DeclaratorSubscriptNode < ASTNode
    def id_node
        @children[0]
    end

    def width_node
        @children[1]
    end

    def evaluate(*)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        width = width_node.evaluate
        debug_log 'Width:', width

        Declarator.new(id, width)
    end
end

class DeclaratorNode < ASTNode
    def id_node
        @children[0]
    end

    def evaluate(*)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        Declarator.new(id, 1)
    end
end
