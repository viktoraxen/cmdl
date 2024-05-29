# frozen_string_literal: true

# !/usr/bin/env ruby

require_relative 'log'
require_relative 'scope'
require_relative 'cmdl_exceptions'

class Node
    attr_accessor :value, :children

    def initialize(*children, value: '')
        @value    = value
        @children = children
    end

    def add_child(child)
        @children << child
        self
    end

    # Deep compare of nodes
    def ==(other)
        return false unless leaf? == other.leaf?

        # If the nodes are leaves, compare their values
        return true if leaf? && @value == other.value

        # If the nodes are not leaves, compare their children
        # Start with size of children lists
        return false unless @children.size == other.children.size

        # Compare each child, children needs to be in the same order
        @children.each_with_index do |child, i|
            return false unless child == other.children[i]
        end

        # All children match, compare the value
        @value == other.value
    end

    def leaf?
        !@children[0].is_a? Node
    end

    def inspect
        to_s
    end

    def to_s
        "<#{self.class}> #{@value}"
    end

    def print(level = 0)
        puts ('|  ' * level) + to_s

        if leaf?
            puts ('|  ' * (level + 1)) + @children[0].to_s
        else
            children.each { |child| child&.print(level + 1) }
        end
    end

    def evaluate(*)
        raise NotImplementedError("Evaluate not implemented for #{self.class} with value #{@value} and children #{@children}")
    end
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

        assign_wires = signal_ids_node.evaluate(scope)
        assigned_wires = assign_wires.select(&:assigned?)
        input_wires = assign_wires.select { |wire| scope.blueprint.wire_is_input?(wire) }

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

class ComponentNode < Node
    def component_id_node
        @children[0]
    end

    def input_ids_node
        @children[1]
    end

    def output_ids_node
        @children[2]
    end

    def statements_node
        @children[3]
    end

    def evaluate(scope, *)
        Log.debug 'ComponentNode.evaluate:', " #{component_id_node}", " #{input_ids_node}", " #{output_ids_node}", " #{statements_node}"

        comp_id = component_id_node.evaluate

        if scope.nil?
            Log.debug 'ComponentNode.evaluate:', 'Creating new scope for component', comp_id.to_s
            scope = Scope.new(comp_id)
        else
            Log.debug 'ComponentNode.evaluate:', 'Adding subscope for component', comp_id.to_s
            new_scope = scope.add_subscope(comp_id)

            raise DuplicateComponentException.new(comp_id, scope) if new_scope.nil?

            scope = new_scope
        end

        input_ids_node.evaluate(scope).each do |input_id|
            wire = scope.blueprint.create_input_wire(input_id)
            scope.blueprint.declare_wire(wire)
        end

        output_ids_node.evaluate(scope).each do |output_id|
            wire = scope.blueprint.create_output_wire(output_id)
            scope.blueprint.declare_wire(wire)
        end

        statements_node.evaluate(scope)

        scope
    end
end

class ConstantNode < Node
    def value
        @children[0]
    end

    def evaluate(*)
        Log.debug 'ConstantNode.evaluate:', " #{value}"

        value == '1' ? 'VCC' : 'GND'
    end
end

class DeclareNode < Node
    def signal_ids_node
        @children[0]
    end

    def evaluate(scope, *)
        Log.debug 'DeclareNode.evaluate:', " #{signal_ids_node}"

        wires = signal_ids_node.evaluate(scope)
        declared_wires = wires.select(&:declared)

        Log.debug 'DeclareNode.evaluate:', 'Declared wires:', declared_wires.to_s

        # Raise error if any of the wires are already declared
        if declared_wires.size.positive?
            raise DuplicateSignalDeclarationException.new(declared_wires.map(&:name), scope)
        end

        wires.each { |wire| scope.blueprint.declare_wire(wire) }
    end
end

class DefineNode < Node
    def signal_ids_node
        @children[0]
    end

    def expression_node
        @children[1]
    end

    def evaluate(scope, *)
        Log.debug 'DefineNode.evaluate:', signal_ids_node.to_s, '<=', expression_node.to_s

        declare_wires = signal_ids_node.evaluate(scope)
        declared_wires = declare_wires.select(&:declared)

        # Raise error if any of the wires are already declared
        if declared_wires.size.positive?
            raise DuplicateSignalDeclarationException.new(declared_wires.map(&:name), scope)
        end

        expr_output_wires = expression_node.evaluate(scope, declare_wires.size)

        # Declare the wires
        declare_wires.each do |wire|
            scope.blueprint.declare_wire(wire)
        end

        scope.blueprint.assign_wires(expr_output_wires, declare_wires)
    end
end

class IdNode < Node
    def value
        @children[0]
    end

    def evaluate(*)
        Log.debug 'IdNode.evaluate:', value.to_s

        value
    end
end

class ListNode < Node
    def evaluate(*args)
        Log.debug 'ListNode.evaluate:', @children.to_s

        @children.map { |child| child.evaluate(*args) }
    end
end

class SignalNode < Node
    def id_node
        @children[0]
    end

    def evaluate(scope, *)
        # TODO: Add dynamic scope search. Search through parent scope until found
        Log.debug 'SignalNode.evaluate:', 'Getting signal', id_node.to_s

        scope.blueprint.create_wire(id_node.evaluate)
    end
end

class StatementsNode < Node
    def evaluate(scope, *)
        Log.debug 'StatementsNode.evaluate:', @children.to_s

        @children.each do |child|
            Log.debug ''
            child.evaluate(scope)
        end

        scope.blueprint.cleanup

        undeclared_wires = scope.blueprint.undeclared_wires

        raise UndeclaredSignalsException.new(undeclared_wires.map(&:name), scope) unless undeclared_wires.empty?

        scope
    end
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
