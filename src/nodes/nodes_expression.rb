# frozen_string_literal: true

require_relative 'nodes_core'

class BinaryExpressionNode < Node
    def lh_expr_node
        @children[0]
    end

    def op_node
        @children[1]
    end

    def rh_expr_node
        @children[2]
    end

    def evaluate(scope, *)
        debug_log

        lh_output_wires = lh_expr_node.evaluate(scope)
        debug_log "Left Output Wires:", lh_output_wires

        rh_output_wires = rh_expr_node.evaluate(scope)
        debug_log "Right Output Wires:", rh_output_wires

        operation = op_node.evaluate
        debug_log "Operation", lh_output_wires

        "#{lh_output_wires} #{operation} #{rh_output_wires}"

        # scope.blueprint.create_connection(operation, lh_output_wires + rh_output_wires).outputs
    end
end

class ComponentExpressionNode < Node
    def component_id_node
        @children[0]
    end

    def inputs_node
        @children[1]
    end

    def evaluate(scope, num_outputs = 1, *)
        debug_log

        comp_id     = component_id_node.evaluate
        debug_log "Component Id:", comp_id

        input_wires = inputs_node.evaluate(scope)
        debug_log "Input Wires:", input_wires

        "#{comp_id}(#{input_wires.join(', ')})"
        # scope.blueprint.create_connection(comp_id, input_wires, num_outputs).outputs[0..num_outputs - 1]
    end
end

class ExpressionListNode < FlatListNode
end

class UnaryExpressionNode < Node
    def op_node
        @children[0]
    end

    def expr_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        expr_output_wires = expr_node.evaluate(scope)

        debug_log "Expression Output Wires:", expr_output_wires

        operation = op_node.evaluate

        debug_log "Operation:", operation

        "#{operation} #{expr_output_wires}"
        # scope.blueprint.create_connection(operation, expr_output_wires).outputs
    end
end
