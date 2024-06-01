# frozen_string_literal: true

require_relative 'rdparse'
require_relative 'nodes'

class CmdlParser < Parser
    def initialize(log_level = Logger::DEBUG)
        super('Component Description Languague', log_level) do
            # Ignore comments
            token(/^\s*#.*\n?$/)

            token(/\s+/)

            token(/<=/)     { |m| m }
            token(/=>/)     { |m| m }
            token(/[(|)]/)  { |m| m }
            token(/,/)      { |m| m }
            token(/\./)     { |m| m }

            token(/[a-zA-Z][a-zA-Z_0-9]*/) { |m| m }
            token(/[0-9]/)                 { |m| m }

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
                match('component', :id, :statements, 'end') do |_, id, statements, _|
                    ComponentNode.new(id, nil, nil, statements)
                end
                match('component', :id, '(', :ids, ')', '=>', :ids,
                      :statements,
                      'end') do|_, id_node, _, input_ids_node, _, _, output_ids_node, statements_node, _|
                    ComponentNode.new(id_node, input_ids_node, output_ids_node, statements_node)
                end
            end

            rule :declaration do
                match('signal', :signals) do |_, ids|
                    DeclareNode.new(ids)
                end
            end

            rule :assign do
                match(:signals, '<=', :expression) do |ids, _, expr|
                    AssignNode.new(ids, expr)
                end
            end

            rule :definition do
                match('signal', :signals, '<=', :expression) do |_, ids, _, expr|
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
                match(:id, '(', :signals, ')') do |component_id, _, inputs, _|
                    ComponentExpressionNode.new(component_id, inputs)
                end
                match(:expression_primary) { |expr| expr }
            end

            rule :expression_primary do
                match('(', :expression, ')') { |_, expr, _| expr }
                match(:signals)              { |a| a }
            end

            rule :atomics do
                match(:atomics, ',', :atomic) { |inputs, _, input| inputs.add_child(input) }
                match(:atomic)                { |input| ListNode.new(input) }
            end

            rule :atomic do
                match(:constant) { |constant| constant }
                match(:id)       { |id| id }
            end

            rule :signals do
                match(:signals, ',', :signal) { |signals, _, signal| signals.add_child(signal) }
                match(:signal)                { |signal| ListNode.new(signal) }
            end

            rule :signal do
                match(:constant) { |a| SignalNode.new a }
                match(:id)       { |a| SignalNode.new a }
            end

            rule :constants do
                match(:constants, ',', :constant) { |constants, _, constant| constants.add_child(constant) }
                match(:constant)                  { |constant| ListNode.new(constant) }
            end

            rule :ids do
                match(:ids, ',', :id) { |ids, _, id| ids.add_child(id) }
                match(:id)            { |id| ListNode.new(id) }
            end

            rule :id do
                match(/^[a-zA-Z][a-zA-Z0-9_]*$/) { |a| IdNode.new a }
            end

            rule :constant do
                match(/^[0-9]+$/) { |a| ConstantNode.new a }
            end
        end
    end
end
