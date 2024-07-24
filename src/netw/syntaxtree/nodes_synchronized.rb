# frozen_string_literal: true

require_relative 'nodes_core'

require_relative '../types/signature'

require_relative '../../core/error/cmdl_assert'

class SynchronizedNode < ScopeNode
end

class SynchronizedInputListNode < FlatListNode
end

class SynchronizedSyncNode < DeclaratorNode
    def evaluate(*)
        super(nil, :sync)
    end
end

class SynchronizedInputSubscriptNode < DeclaratorSubscriptNode
    def evaluate(*)
        super(nil, :input)
    end
end

class SynchronizedInputNode < DeclaratorNode
    def evaluate(*)
        super(nil, :input)
    end
end

class SynchronizedOutputListNode < FlatListNode
end

class SynchronizedOutputSubscriptNode < DeclaratorSubscriptNode
    def evaluate(*)
        super(nil, :output)
    end
end

class SynchronizedOutputNode < DeclaratorNode
    def evaluate(*)
        super(nil, :output)
    end
end

class SynchronizedSignatureNode < SignatureNode
    def sync_node
        @children[1]
    end

    def inputs_node
        @children[2]
    end

    def outputs_node
        @children[3]
    end

    def evaluate(*)
        signature = super

        sync = sync_node.evaluate
        debug_log 'Sync signal:', sync

        assert_valid_synchronized(signature, sync)

        signature.sync = sync
        signature
    end
end
