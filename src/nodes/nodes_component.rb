# frozen_string_literal: true

require_relative 'nodes_core'

class ComponentNode < Node
    def component_id_node
        @children[0]
    end

    def input_ids_node
        @children[1]
    end

    def output_ids_node
        @children[2]
    end

    def statements_node
        @children[3]
    end

    def evaluate(scope, *)
        Log.debug 'ComponentNode.evaluate:', " #{component_id_node}", " #{input_ids_node}", " #{output_ids_node}", " #{statements_node}"

        comp_id = component_id_node.evaluate

        if scope.nil?
            Log.debug 'ComponentNode.evaluate:', 'Creating new scope for component', comp_id.to_s
            scope = Scope.new(comp_id)
        else
            Log.debug 'ComponentNode.evaluate:', 'Adding subscope for component', comp_id.to_s
            new_scope = scope.add_subscope(comp_id)

            raise DuplicateComponentException.new(comp_id, scope) if new_scope.nil?

            scope = new_scope
        end

        input_ids_node.evaluate(scope).each do |input_id|
            wire = scope.blueprint.create_input_wire(input_id)
            scope.blueprint.declare_wire(wire)
        end

        output_ids_node.evaluate(scope).each do |output_id|
            wire = scope.blueprint.create_output_wire(output_id)
            scope.blueprint.declare_wire(wire)
        end

        statements_node.evaluate(scope)

        scope
    end
end

class ComponentInputListNode < FlatListNode
end

class ComponentOutputListNode < FlatListNode
end

class ComponentSignatureNode < Node
end
