# frozen_string_literal: true

require_relative 'nodes_expression'

require_relative '../../core/error/cmdl_assert'

module BinaryExpression
    def lh_expr_node
        @children[0]
    end

    def op_node
        @children[1]
    end

    def rh_expr_node
        @children[2]
    end

    def evaluate_child_nodes(scope, *)
        debug_log

        @lh_refs = lh_expr_node.evaluate(scope)
        debug_log 'Left Outputs:', @lh_refs

        @rh_refs = rh_expr_node.evaluate(scope)
        debug_log 'Right Outputs:', @rh_refs

        @operation = op_node.evaluate
        debug_log 'Operation', @operation
    end
end

class BinaryGateExpressionNode < ASTNode
    include BinaryExpression

    def evaluate(scope, *)
        evaluate_child_nodes(scope)

        assert_valid_binary_gate_expression(scope, @lh_refs, @rh_refs, @operation)

        scope.template.add_binary(@operation, @lh_refs, @rh_refs)
    end
end

class NorExpressionNode < ASTNode
    include BinaryExpression

    def evaluate(scope, *)
        evaluate_child_nodes(scope)

        assert_valid_nor_expression(scope, @lh_refs, @rh_refs)

        or_refs = scope.template.add_binary('or', @lh_refs, @rh_refs)

        scope.template.add_unary('not', or_refs)
    end
end

class NandExpressionNode < ASTNode
    include BinaryExpression

    def evaluate(scope, *)
        evaluate_child_nodes(scope)

        assert_valid_nand_expression(scope, @lh_refs, @rh_refs)

        and_refs = scope.template.add_binary('and', @lh_refs, @rh_refs)

        scope.template.add_unary('not', and_refs)
    end
end

class XorExpressionNode < ASTNode
    include BinaryExpression

    def evaluate(scope, *)
        evaluate_child_nodes(scope)

        # assert_valid_nand_expression(scope, @lh_refs, @rh_refs)

        not_lh_refs = scope.template.add_unary('not', @lh_refs)
        not_rh_refs = scope.template.add_unary('not', @rh_refs)

        lh_or_refs = scope.template.add_binary('and', not_lh_refs, @rh_refs)
        rh_or_refs = scope.template.add_binary('and', @lh_refs, not_rh_refs)

        scope.template.add_binary('or', lh_or_refs, rh_or_refs)
    end
end

class XnorExpressionNode < XorExpressionNode
    def evaluate(scope, *)
        xor_refs = super

        # assert_valid_nand_expression(scope, @lh_refs, @rh_refs)
        scope.template.add_unary('not', xor_refs)
    end
end

class EqualsExpressionNode < XnorExpressionNode
    def evaluate(scope, *)
        xnor_refs = super

        xnor_refs.map do |ref|
            bit_refs = (0...scope.template._signal_subscript_width(ref)).map do |i|
                Reference.new(ref.id, SubscriptIndex.new(i))
            end

            bit_refs.reduce do |acc, bit_ref|
                scope.template.add_binary('and', acc, bit_ref)
            end
        end
    end
end
