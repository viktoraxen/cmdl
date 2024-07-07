# frozen_string_literal: true

require_relative 'nodes_core'

require_relative '../core/cmdl_assert'
require_relative '../types/constant'

class BinaryExpressionNode < ASTNode
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

        lh_refs = lh_expr_node.evaluate(scope)
        debug_log 'Left Outputs:', lh_refs

        rh_refs = rh_expr_node.evaluate(scope)
        debug_log 'Right Outputs:', rh_refs

        operation = op_node.evaluate
        debug_log 'Operation', operation

        assert_valid_binary_expression(scope, lh_refs, rh_refs, operation)

        scope.template.add_binary(operation, lh_refs, rh_refs)
    end
end

class ComponentExpressionNode < ASTNode
    def component_id_node
        @children[0]
    end

    def inputs_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        comp_id = component_id_node.evaluate
        debug_log 'Component Id:', comp_id

        input_refs = inputs_node.evaluate(scope)
        debug_log 'Inputs:', input_refs

        assert_valid_component_expression(scope, comp_id, input_refs)

        scope.template.add_component(comp_id, input_refs)
    end
end

class ExpressionConstantNode < ASTNode
    def constant_node
        @children[0]
    end

    def evaluate(scope, *)
        debug_log

        constant = constant_node.evaluate
        debug_log 'Constant:', constant

        scope.template.constant(constant)
    end
end

class ExpressionIdentifierNode < ASTNode
    def id_node
        @children[0]
    end

    def evaluate(scope, *)
        debug_log

        id = id_node.evaluate
        debug_log 'Identifier:', id

        scope.template.reference(id)
    end
end

class ExpressionListNode < FlatListNode
end

class ExpressionSubscriptNode < ASTNode
    def expression_node
        @children[0]
    end

    def subscript_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        expression_output_refs = expression_node.evaluate(scope)
        debug_log 'Expression Outputs:', expression_output_refs

        subscript = subscript_node.evaluate
        debug_log 'Subscript:', subscript

        expression_output_refs.map do |output_ref|
            scope.template.reference_add_subscript(output_ref, subscript)
        end
    end
end

class UnaryExpressionNode < ASTNode
    def op_node
        @children[0]
    end

    def expr_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        expr_output_refs = expr_node.evaluate(scope)
        debug_log 'Expression Output Wires:', expr_output_refs

        operation = op_node.evaluate
        debug_log 'Operation:', operation

        scope.template.add_unary(operation, expr_output_refs)
    end
end
