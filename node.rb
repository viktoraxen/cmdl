# frozen_string_literal: true
#

require_relative 'blueprint'

class Node
    @@debug = false

    attr_accessor :value, :children

    def initialize(value, children = nil, logger = Logger.new($stdout))
        @value    = value
        @children = children
        @logger   = logger
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

    def is_interface?
        self.is_a?(InterfaceInNode) || self.is_a?(InterfaceOutNode)
    end

    def leaf?
        @children.nil? || (@children.is_a?(Array) && @children.empty?)
    end

    def inspect
        to_s
    end

    def to_s
        "<#{self.class}>: #{@value}"
    end

    def print(level = 0)
        puts ('|  ' * level) + "#{@value} <#{self.class}>"
        children.each { |child| child.print(level + 1) } unless leaf?
    end

    def evaluate(*)
        raise NotImplementedError("Evaluate not implemented for #{self.class} with value #{@value} and children #{@children}")
    end
end

class AbsoluteScopeNode < Node
    def scope_node
        @children[0]
    end

    def evaluate(blueprint)
        if @@debug
            puts "AbsoluteScopeNode: scope_node #{@children[0]}"
        end

        scope = scope_node.evaluate(blueprint)

        blueprint.find_blueprint_absolute(scope)
    end
end

class AssignNode < Node
    def output_ids_node
        @children[0]
    end

    def input_ids_node
        @children[1]
    end

    def evaluate(blueprint)
        if @@debug
            puts "AssignNode: output_ids_node #{@children[0]}, input_ids_node #{@children[1]}"
        end

        output_ids = output_ids_node.evaluate(blueprint)
        input_ids  = input_ids_node.evaluate(blueprint)

        if output_ids == []
            raise Exception.new('AssignNode: No output ids found!')
            return nil
        end

        if input_ids == []
            raise Exception.new("AssignNode: No input ids found for assignment to #{output_ids}!")
        end

        output_ids.each_with_index do |id, i|
            blueprint.add_assignment(input_ids[i % input_ids.length], id)
        end
    end
end

class BinaryExpressionNode < Node
    def lh_expression_node
        @children[0]
    end

    def rh_expression_node
        @children[1]
    end

    def type
        @value
    end

    def evaluate(blueprint)
        if @@debug
            puts "BinaryExpressionNode: lh_expression_node #{@children[0]}, rh_expression_node #{@children[1]}"
        end

        lh_expression_outputs = lh_expression_node.evaluate(blueprint)
        rh_expression_outputs = rh_expression_node.evaluate(blueprint)

        if lh_expression_outputs == []
            raise Exeption.new("BinaryExpressionNode: No left-hand expression outputs found for expression of type #{type}!")
        end

        if rh_expression_outputs == []
            raise Exception.new("BinaryExpressionNode: No right-hand expression outputs found for expression of type #{type}!")
        end

        blueprint.add_constraint(type, lh_expression_outputs + rh_expression_outputs)
    end
end

class ComponentExpressionNode < Node
    def scope_node
        @children[0]
    end

    def input_ids_node
        @children[1]
    end

    def evaluate(blueprint)
        if @@debug
            puts "ComponentExpressionNode: scope_node #{@children[0]}, input_ids_node #{@children[1]}"
        end

        scope     = scope_node.evaluate(blueprint) unless scope_node.nil?
        input_ids = input_ids_node.evaluate(blueprint)

        if scope == blueprint
            raise Exeption.new("ComponentExpressionNode: Used scope (#{scope}) is same as current scope (#{blueprint})!")
        end

        if input_ids == []
            raise Exeption.new("ComponentExpressionNode: No input ids found for component expression #{scope.full_name}!")
        end

        @logger.debug("ComponentExpressionNode: Adding connection to #{scope.full_name} with input ids #{input_ids}")
        # blueprint.add_connection(scope, input_ids)
    end
end

class ComponentBodyNode < Node
    def statement_nodes
        @children
    end

    # def evaluate_interfaces(blueprint)
    #     # Evaluate only the nodes contributing to interface-network
    #     statement_nodes.each do |node|
    #         if node.is_interface?
    #             node.evaluate(blueprint)
    #         elsif node.is_a?(ComponentNode)
    #             blueprint.add_blueprint(node.evaluate_interfaces(blueprint))
    #         end
    #     end

    #     # Remove nodes so they don't get evaluated in the second traversal
    #     statement_nodes.delete_if(&:is_interface?)
    # end

    def evaluate(blueprint)
        if @@debug
            puts "ComponentBodyNode: statement_nodes #{statement_nodes}"
        end

        statement_nodes.each do |node|
            node.evaluate(blueprint)
        end
    end
end

class ComponentIdNode < Node
    def id
        @value
    end

    def evaluate
        if @@debug
            puts "ComponentIdNode: id #{@value}"
        end

        if @value.nil?
            raise Exception.new('ComponentIdNode: Id is nil!')
        end

        id
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

    def evaluate_scopes
        name = component_id_node.evaluate
        statements = statements_node.children

        scopes = []

        statements.each do |node|
            next unless node.is_a?(ComponentNode)

            node.evaluate_scopes.each do |scope|
                new_scope = "#{name}.#{scope}"

                if scopes.include?(new_scope)
                    raise Exception.new("ComponentNode: Scope #{new_scope} already exists!")
                end

                scopes << new_scope
            end
        end

        scopes << name
    end

    def evaluate(blueprint)
        if @@debug
            puts "ComponentNode: component_id_node #{@children[0]}, component_body_node #{@children[1]}"
        end

        name       = component_id_node.evaluate(blueprint)
        input_ids  = input_ids_node.evaluate(blueprint)
        output_ids = output_ids_node.evaluate(blueprint)
        # new_scope  = blueprint.get_blueprint(name)

        statements_node.evaluate(blueprint)
        # component_body_node.evaluate(new_scope)
    end
end

class ConstantNode < Node
    def evaluate(_)
        if @@debug
            puts "ConstantNode: value #{@value}"
        end

        if @value.nil?
            raise Exeption.new('ConstantNode: Value is nil!')
        end

        [@value]
    end
end

class DeclareNode < Node
    def ids_node
        @children[0]
    end

    def evaluate(blueprint)
        if @@debug
            puts "DeclareNode: ids_node #{@children[0]}"
        end

        ids = ids_node.evaluate(blueprint)

        ids.each do |id|
            blueprint.add_wire(id)
        end
    end
end

class DefineNode < Node
    def declaration_node
        @children[0]
    end

    def assignment_node
        @children[1]
    end

    def evaluate(blueprint)
        if @@debug
            puts "DefineNode: declaration_node #{@children[0]}, assignment_node #{@children[1]}"
        end

        assignment_node.evaluate(blueprint)
    end
end

class FileNode < Node
    def statements_node
        @children[0]
    end

    # def evaluate_interfaces(blueprint = Blueprint.new)
    #     statement_nodes.each do |node|
    #         if node.is_a?(ComponentNode)
    #             blueprint.add_blueprint(node.evaluate_interfaces(blueprint))
    #         end
    #     end

    #     blueprint
    # end
    def evaluate_scopes
        statements = statements_node.children

        scopes = []

        statements.each do |node|
            scopes << node.evaluate_scopes if node.is_a?(ComponentNode)
        end

        scopes.flatten
    end

    def evaluate(blueprint = Blueprint.new)
        if @@debug
            puts "FileNode: statement_nodes #{@children}"
        end

        scopes = evaluate_scopes

        statements_node.evaluate(blueprint)

        blueprint
    end
end

class RelativeScopeNode < Node
    def scope_node
        @children[0]
    end

    def evaluate(blueprint)
        if @@debug
            puts "RelativeScopeNode: scope_node #{@children[0]}"
        end

        scope = scope_node.evaluate(blueprint)
        @logger.debug("RelativeScopeNode: #{scope}")

        # blueprint.find_blueprint_relative(scope)
    end
end

class ScopePathNode < Node
    def evaluate(blueprint)
        if @@debug
            puts "ScopePathNode: children #{@children}"
        end

        @children.map do |child|
            child.evaluate(blueprint)
        end
    end
end

class StatementsNode < Node
    def evaluate(blueprint)
        if @@debug
            puts "StatementsNode: children #{@children}"
        end

        @children.each do |child|
            child.evaluate(blueprint)
        end
    end
end

class SignalIdsNode < Node
    def evaluate(blueprint)
        if @@debug
            puts "SignalIdsNode: children #{@children}"
        end

        ids_list = @children.map do |node|
            node.evaluate(blueprint)
        end

        ids_list.flatten
    end
end

class SignalIdNode < Node
    def evaluate(_)
        if @@debug
            puts "SignalIdNode: value #{@value}"
        end

        if @value.nil?
            raise Exception.new('SignalIdNode: Value is nil!')
            return nil
        end

        [@value]
    end
end

class UnaryExpressionNode < Node
    def type
        @value
    end

    def expression
        @children[0]
    end

    def evaluate(blueprint)
        if @@debug
            puts "UnaryExpressionNode: expression #{@children[0]}"
        end

        expression_outputs = expression.evaluate(blueprint)

        if expression_outputs == []
            raise Exception.new("UnaryExpressionNode: No expression outputs found for expression of type #{type}!")
        end

        blueprint.add_constraint(type, expression_outputs)
    end
end
