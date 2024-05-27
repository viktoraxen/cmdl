# frozen_string_literal: true

require_relative 'rdparse'
require_relative 'node'

class CmdlParser < Parser
    def initialize(log_level = Logger::DEBUG)
        super('Component Description Languague', log_level) do
            # Ignore comments
            token(/^\s*#.*\n?$/)

            token(/\s+/)

            token(/<=/)        { |m| m }
            token(/[(|)]/)     { |m| m }
            token(/,/)         { |m| m }
            token(/\./)         { |m| m }

            token(/[a-zA-Z]+/) { |m| m }
            token(/[0|1]/)     { |m| m }

            start :file do
                match(:statements) { |a| FileNode.new('sequence', a) }
            end

            rule :statements do
                match(:statements, :statement) { |list, a| list << a }
                match(:statement)              { |a| [a] }
            end

            rule :statement do
                match(:component_declaration) { |a| a }
                match(:assign)                { |a| a }
                match(:signal_definition)     { |a| a }
                match(:signal_declaration)    { |a| a }
            end

            rule :component_declaration do
                match('component', :component_id, :component_body, 'end') do |_, id, body, _|
                    ComponentNode.new('component', [id, body])
                end
            end

            rule :component_body do
                match(:component_statements) do |a|
                    ComponentBodyNode.new('component body', a)
                end
                match do
                    ComponentBodyNode.new('component body', [])
                end
            end

            rule :component_statements do
                match(:component_statements, :component_statement) { |list, a| list << a }
                match(:component_statement)                        { |a| [a] }
            end

            rule :component_statement do
                match(:interface)             { |a| a }
                match(:component_declaration) { |a| a }
                match(:assign)                { |a| a }
                match(:signal_definition)     { |a| a }
                match(:signal_declaration)    { |a| a }
            end

            rule :interface do
                match(:interface_in)  { |a| a }
                match(:interface_out) { |a| a }
            end

            rule :interface_in do
                match('interface', 'in', :signal_ids) do |_, _, ids|
                    InterfaceInNode.new('interface in', [ids])
                end
            end

            rule :interface_out do
                match('interface', 'out', :signal_ids) do |_, _, ids|
                    InterfaceOutNode.new('interface out', [ids])
                end
            end

            rule :assign do
                match(:signal_ids, '<=', :expression) do |ids, _, expr|
                    AssignNode.new('assign', [ids, expr])
                end
            end

            rule :signal_definition do
                match('signal', :signal_ids, '<=', :expression) do |_, ids, _, expr|
                    declare_node = DeclareNode.new('declare', [ids])
                    assign_node  = AssignNode.new('assign', [ids, expr])
                    DefineNode.new('define', [declare_node, assign_node])
                end
            end

            rule :signal_declaration do
                match('signal', :signal_ids) do |_, ids|
                    DeclareNode.new('declare', [ids])
                end
            end

            rule :expression do
                match(:expression_or) { |expr| expr }
            end

            rule :expression_or do
                match(:expression_or, 'or', :expression_and) do |lh, op, rh|
                    BinaryExpressionNode.new(op, [lh, rh])
                end
                match(:expression_and) { |expr| expr }
            end

            rule :expression_and do
                match(:expression_and, 'and', :expression_not) do |lh, op, rh|
                    BinaryExpressionNode.new(op, [lh, rh])
                end
                match(:expression_not) { |expr| expr }
            end

            rule :expression_not do
                match('not', :expression_not) do |op, expr|
                    UnaryExpressionNode.new(op, [expr])
                end
                match(:expression_component) { |expr| expr }
            end

            rule :expression_component do
                match(:scope, '(', :signal_ids, ')') do |scope, _, input_ids, _|
                    ComponentExpressionNode.new('component expression', [scope, input_ids])
                end
                match(:expression_primary) { |expr| expr }
            end

            rule :expression_primary do
                match('(', :expression, ')') { |_, expr, _| expr }
                match(:constant) { |a| a }
                match(:signal_id) { |a| a }
            end

            rule :bin_op do
                match('and') { |a| a }
                match('or')  { |a| a }
            end

            rule :un_op do
                match('not') { |a| a }
            end

            rule :scope do
                match(:relative_scope) { |a| a }
                match(:absolute_scope) { |a| a }
            end

            rule :absolute_scope do
                match('.', :scope_path) { |_, path| AbsoluteScopeNode.new('absolute scope', [path]) }
            end

            rule :relative_scope do
                match(:scope_path) { |path| RelativeScopeNode.new('relative scope', [path]) }
            end

            rule :scope_path do
                match(:scope_path, '.', :component_id) { |path, _, id| path.add_child(id) }
                match(:component_id)                   { |id| ScopePathNode.new('scope path', [id]) }
            end

            rule :component_id do
                match(/[A-Z][a-zA-Z]*/) { |a| ComponentIdNode.new a }
            end

            rule :signal_ids do
                match(:signal_ids, ',', :signal_id) { |ids, _, id| ids.add_child(id) }
                match(:signal_id)                   { |id| SignalIdsNode.new('ids', [id]) }
            end

            rule :signal_id do
                match(/[a-z][a-zA-Z_]*/) { |a| SignalIdNode.new a }
            end

            rule :constant do
                match(/[0|1]/) { |a| ConstantNode.new a }
            end
        end
    end
end
