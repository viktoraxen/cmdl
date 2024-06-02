# frozen_string_literal: true

require_relative 'nodes_core'

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
        debug_log

        assign_wires   = signal_ids_node.evaluate(scope)

        debug_log "Assign Wires:", assign_wires

        # assigned_wires = assign_wires.select(&:assigned?)
        # input_wires    = assign_wires.select { |wire| scope.blueprint.wire_is_input?(wire) }

        # Raise error if any of the wires are already assigned
        # if assigned_wires.size.positive?
        #     raise SignalReassignmentException.new(assigned_wires.map(&:name), scope)
        # end

        # Raise error if any of the wires are already assigned
        # if input_wires.size.positive?
        #     raise InputSignalAssignmentException.new(input_wires.map(&:name), scope)
        # end

        expr_output_wires = expression_node.evaluate(scope, assign_wires.size)

        debug_log "Expression Output Wires:", expr_output_wires

        # scope.blueprint.assign_wires(expr_output_wires, assign_wires)
    end
end
