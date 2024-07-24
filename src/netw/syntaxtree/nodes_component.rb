# frozen_string_literal: true

require_relative 'nodes_core'
require_relative 'nodes_declaration'

require_relative '../types/signature'

require_relative '../../core/error/cmdl_assert'

class ComponentNode < ScopeNode
end

class ComponentInputListNode < FlatListNode
end

class ComponentInputSubscriptNode < DeclaratorSubscriptNode
    def evaluate(*)
        super(nil, :input)
    end
end

class ComponentInputNode < DeclaratorNode
    def evaluate(*)
        super(nil, :input)
    end
end

class ComponentOutputListNode < FlatListNode
end

class ComponentOutputSubscriptNode < DeclaratorSubscriptNode
    def evaluate(*)
        super(nil, :output)
    end
end

class ComponentOutputNode < DeclaratorNode
    def evaluate(*)
        super(nil, :output)
    end
end

class ComponentSignatureNode < SignatureNode
end
