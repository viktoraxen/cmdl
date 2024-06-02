# frozen_string_literal: true

require_relative 'nodes_core'

class DeclarationNode < Node
    def declarators_node
        @children[0]
    end

    def expressions_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        wires = declarators_node.evaluate(scope)

        debug_log "Declarators:", wires

        # declared_wires = wires.select{ |w| scope.blueprint.wire_declared?(w) }

        # Raise error if any of the wires are already declared
        # if declared_wires.size.positive?
        #     raise DuplicateSignalDeclarationException.new(declared_wires, scope)
        # end

        # Declare the wires
        # wires.each { |wire| scope.blueprint.declare_wire(wire) }

        return wires if expressions_node.nil?

        expr_output_wires = expressions_node.evaluate(scope, wires.size)

        debug_log "Expressions:", expr_output_wires

        # Assign the wires if expressions are given
        # scope.blueprint.assign_wires(expr_output_wires, declare_wires)
    end
end

class DeclaratorListNode < FlatListNode
end
