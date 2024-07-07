# frozen_string_literal: true

require_relative 'nodes_core'

require_relative '../core/cmdl_assert'

class AssignmentReceiverListNode < FlatListNode
end

class AssignNode < ASTNode
    def receivers_node
        @children[0]
    end

    def expression_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        receiver_refs = receivers_node.evaluate(scope)
        debug_log "Assignment Receivers:", receiver_refs

        value_refs = expression_node.evaluate(scope)
        debug_log "Assignment Values:", value_refs

        assert_valid_assignment(scope, receiver_refs, value_refs)

        scope.template.assign(receiver_refs, value_refs)
    end
end

class AssignmentReceiverSubscriptNode < ASTNode
    def id_node
        @children[0]
    end

    def subscript_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        subscript = subscript_node.evaluate
        debug_log 'Subscript:', subscript

        scope.template.reference(id, subscript)
    end
end

class AssignmentReceiverNode < ASTNode
    def id_node
        @children[0]
    end

    def evaluate(scope, *)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        scope.template.reference(id)
    end
end
