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
        Log.debug 'BinaryExpressionNode.evaluate:', lh_expr_node.to_s, op_node.to_s, rh_expr_node.to_s

        lh_output_wires = lh_expr_node.evaluate(scope)
        rh_output_wires = rh_expr_node.evaluate(scope)
        operation = op_node.evaluate

        scope.blueprint.create_connection(operation, lh_output_wires + rh_output_wires).outputs
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
        Log.debug 'ComponentExpressionNode.evaluate:', component_id_node.to_s, inputs_node.to_s

        comp_id     = component_id_node.evaluate
        input_wires = inputs_node.evaluate(scope)

        scope.blueprint.create_connection(comp_id, input_wires, num_outputs).outputs[0..num_outputs - 1]
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
        Log.debug 'UnaryExpressionNode.evaluate:', op_node.to_s, expr_node.to_s

        expr_output_wires = expr_node.evaluate(scope)
        operation         = op_node.evaluate

        scope.blueprint.create_connection(operation, expr_output_wires).outputs
    end
end
