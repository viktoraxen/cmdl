# frozen_string_literal: true

require_relative 'nodes_core'

class ComponentNode < Node
    def signature_node
        @children[0]
    end

    def statements_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        signature = signature_node.evaluate
        debug_log 'Signature:', signature

        # if scope.nil?
        #     Log.debug 'ComponentNode.evaluate:', 'Creating new scope for component', comp_id.to_s
        #     scope = Scope.new(comp_id)
        # else
        #     Log.debug 'ComponentNode.evaluate:', 'Adding subscope for component', comp_id.to_s
        #     new_scope = scope.add_subscope(comp_id)

        #     raise DuplicateComponentException.new(comp_id, scope) if new_scope.nil?

        #     scope = new_scope
        # end

        # input_ids_node.evaluate(scope).each do |input_id|
        #     wire = scope.blueprint.create_input_wire(input_id)
        #     scope.blueprint.declare_wire(wire)
        # end

        # output_ids_node.evaluate(scope).each do |output_id|
        #     wire = scope.blueprint.create_output_wire(output_id)
        #     scope.blueprint.declare_wire(wire)
        # end

        statements_node.evaluate(scope)

        scope
    end
end

class ComponentInputListNode < FlatListNode
end

class ComponentOutputListNode < FlatListNode
end

class ComponentSignatureNode < Node
    def id_node
        @children[0]
    end

    def inputs_node
        @children[1]
    end

    def outputs_node
        @children[2]
    end

    def evaluate(*)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        inputs = inputs_node.evaluate
        debug_log 'Inputs:', inputs

        outputs = outputs_node.evaluate
        debug_log 'Outputs:', outputs

        {
            id: id,
            inputs: inputs,
            outputs: outputs,
        }
    end
end
