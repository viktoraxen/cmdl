# frozen_string_literal: true

require_relative 'nodes_core'

require_relative '../types/signature'

require_relative '../core/cmdl_assert'

class ComponentNode < ASTNode
    def signature_node
        @children[0]
    end

    def statements_node
        @children[1]
    end

    def evaluate(scope, *)
        debug_log

        signature = signature_node.evaluate(scope)

        scope = scope.find_scope(signature.id)

        statements_node.evaluate(scope)

        scope
    end
end

class ComponentInputListNode < FlatListNode
end

class ComponentInputSubscriptNode < ASTNode
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

        Declarator.new(id, width, type: :input)
    end
end

class ComponentInputNode < ASTNode
    def id_node
        @children[0]
    end

    def evaluate(*)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        Declarator.new(id, 1, type: :input)
    end
end

class ComponentOutputListNode < FlatListNode
end

class ComponentOutputSubscriptNode < ASTNode
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

        Declarator.new(id, width, type: :output)
    end
end

class ComponentOutputNode < ASTNode
    def id_node
        @children[0]
    end

    def evaluate(*)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        Declarator.new(id, 1, type: :output)
    end
end

class ComponentSignatureNode < ASTNode
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

        assert_valid_component_signature id, inputs, outputs

        Signature.new(id, inputs, outputs)
    end
end
