# frozen_string_literal: true

require_relative 'rdparse'
require_relative 'nodes'

class CmdlParser < Parser
    def initialize(log_level = Logger::DEBUG)
        super('Component Description Languague', log_level) do
            # Ignore comments
            token(/^\s*#.*\n?$/)

            token(/\s+/)

            token(/<=/)        { |m| m }
            token(/=>/)        { |m| m }
            token(/[(|)]/)     { |m| m }
            token(/,/)         { |m| m }
            token(/\./)        { |m| m }

            token(/[a-zA-Z]+/) { |m| m }
            token(/[0|1]/)     { |m| m }

            start :start do
                match(:statements) { |a| a }
            end

            rule :statements do
                match(:statements, :statement) { |node, statement| node.add_child(statement) }
                match(:statement)              { |statement| StatementsNode.new(statement) }
                match()                        { StatementsNode.new() }
            end

            rule :statement do
                match(:component)   { |a| a }
                match(:assign)      { |a| a }
                match(:definition)  { |a| a }
                match(:declaration) { |a| a }
            end

            rule :component do
                match('component', :component_id, :statements, 'end') do |_, id, statements, _|
                    ComponentNode.new(id, nil, nil, statements)
                end
                match('component', :component_id, '(', :signal_ids, ')', '=>', :signal_ids,
                      :statements,
                      'end') do 
                    |_, id_node, _, input_ids_node, _, _, output_ids_node, statements_node, _|
                        # input_ids_node.value = 'inputs'
                        # output_ids_node.value = 'outputs'
                        # statements_node.value = 'statements'
                        ComponentNode.new(id_node, input_ids_node, output_ids_node, statements_node)
                end
            end

            rule :declaration do
                match('signal', :signal_ids) do |_, ids|
                    DeclareNode.new(ids)
                end
            end

            rule :assign do
                match(:signal_ids, '<=', :expression) do |ids, _, expr|
                    AssignNode.new(ids, expr)
                end
            end

            rule :definition do
                match('signal', :signal_ids, '<=', :expression) do |_, ids, _, expr|
                    DefineNode.new(ids, expr)
                end
            end

            rule :expression do
                match(:expression_or) { |expr| expr }
            end

            rule :expression_or do
                match(:expression_or, 'or', :expression_and) do |lh, op, rh|
                    BinaryExpressionNode.new(lh, IdNode.new(op), rh)
                end
                match(:expression_and) { |expr| expr }
            end

            rule :expression_and do
                match(:expression_and, 'and', :expression_not) do |lh, op, rh|
                    BinaryExpressionNode.new(lh, IdNode.new(op), rh)
                end
                match(:expression_not) { |expr| expr }
            end

            rule :expression_not do
                match('not', :expression_not) do |op, expr|
                    UnaryExpressionNode.new(IdNode.new(op), expr)
                end
                match(:expression_component) { |expr| expr }
            end

            rule :expression_component do
                match(:component_id, '(', :atomics, ')') do |component_id, _, inputs, _|
                    ComponentExpressionNode.new(component_id, inputs)
                end
                match(:expression_primary) { |expr| expr }
            end

            rule :expression_primary do
                match('(', :expression, ')') { |_, expr, _| expr }
                match(:atomics)              { |a| a }
            end

            # rule :expression_constant do
            #     match(:constant) { |a| ConstantExpressionNode.new(a) }
            # end

            # rule :expression_signal do
            #     match(:signal_id) { |a| SignalExpressionNode.new(a) }
            # end

            # rule :scope do
            #     match(:relative_scope) { |a| a }
            #     match(:absolute_scope) { |a| a }
            # end

            # rule :absolute_scope do
            #     match('.', :scope_path) { |_, path| AbsoluteScopeNode.new('absolute scope', [path]) }
            # end

            # rule :relative_scope do
            #     match(:scope_path) { |path| RelativeScopeNode.new('relative scope', [path]) }
            # end

            # rule :scope_path do
            #     match(:scope_path, '.', :component_id) { |path, _, id| path.add_child(id) }
            #     match(:component_id)                   { |id| ScopePathNode.new('scope path', [id]) }
            # end

            rule :component_id do
                match(/[A-Z][a-zA-Z]*/) { |a| IdNode.new a }
            end

            rule :atomics do
                match(:atomics, ',', :atomic) { |inputs, _, input| inputs.add_child(input) }
                match(:atomic)                { |input| ListNode.new(input) }
            end

            rule :atomic do
                match(:signal_id) { |id| id }
                match(:constant)  { |constant| constant }
            end

            rule :signal_ids do
                match(:signal_ids, ',', :signal_id) { |ids, _, id| ids.add_child(id) }
                match(:signal_id)                   { |id| ListNode.new(id) }
            end

            rule :signal_id do
                match(/[a-z][a-zA-Z_]*/) { |a| SignalNode.new a }
            end

            rule :constants do
                match(:constants, ',', :constant) { |constants, _, constant| constants.add_child(constant) }
                match(:constant)                  { |constant| ListNode.new(constant) }
            end

            rule :constant do
                match(/[0|1]/) { |a| ConstantNode.new a }
            end
        end
    end
end
