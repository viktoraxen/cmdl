# frozen_string_literal: true

require_relative 'nodes_core'

class AssigneeNode < Node
    def id_node
        @children[0]
    end

    def index_node
        @children[1]
    end

    def evaluate(scope, *)
        Log.debug 'AssigneeNode.evaluate:', id_node.to_s, index_node.to_s

        id    = id_node.evaluate
        index = index_node.evaluate

        scope.blueprint.find_wire(id, index)
    end
end

class AssigneeListNode < FlatListNode
end

class AssignNode < Node
    def signal_ids_node
        @children[0]
    end

    def expression_node
        @children[1]
    end

    def evaluate(scope, *)
        Log.debug 'AssignNode.evaluate:', signal_ids_node.to_s, ' <= ', expression_node.to_s

        assign_wires   = signal_ids_node.evaluate(scope)
        assigned_wires = assign_wires.select(&:assigned?)
        input_wires    = assign_wires.select { |wire| scope.blueprint.wire_is_input?(wire) }

        # Raise error if any of the wires are already assigned
        if assigned_wires.size.positive?
            raise SignalReassignmentException.new(assigned_wires.map(&:name), scope)
        end

        # Raise error if any of the wires are already assigned
        if input_wires.size.positive?
            raise InputSignalAssignmentException.new(input_wires.map(&:name), scope)
        end

        expr_output_wires = expression_node.evaluate(scope, assign_wires.size)

        scope.blueprint.assign_wires(expr_output_wires, assign_wires)
    end
end
