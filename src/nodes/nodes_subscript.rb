# frozen_string_literal: true

require_relative 'nodes_core'

class SubscriptSpanNode < Node
    def id_node
        @children[0]
    end

    def span_node
        @children[1]
    end

    def evaluate(*)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        span = span_node.evaluate
        debug_log 'Span:', span

        span.map { |i| "#{id}[#{i}]" }
    end
end

class SubscriptIndexNode < Node
    def id_node
        @children[0]
    end

    def index_node
        @children[1]
    end

    def evaluate(*)
        debug_log

        id = id_node.evaluate
        debug_log 'Id:', id

        index = index_node.evaluate
        debug_log 'Index:', index

        "#{id}[#{index}]"
    end
end

class SpanNode < Node
    def start_node
        @children[0]
    end

    def end_node
        @children[1]
    end

    def evaluate(*)
        debug_log

        start_index = start_node.evaluate
        debug_log 'Start Index:', start_index

        end_index = end_node.evaluate
        debug_log 'End Index:', end_index

        if start_index > end_index && end_index >= 0
            raise(IndexError, 'Slice start higher than end.')
        end

        (start_index..end_index - 1)
    end
end

class IndexNode < Node
    def start_node
        @children[0]
    end

    def evaluate(*)
        debug_log

        index = start_node.evaluate
        debug_log 'Index:', index

        index
    end
end
