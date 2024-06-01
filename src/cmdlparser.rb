# frozen_string_literal: true

require_relative 'rdparse'
require_relative 'nodes'

class CmdlParser < Parser
    def initialize(log_level = Logger::DEBUG)
        super('Component Description Languague', log_level) do
            # Ignore comments
            token(/^\s*#.*\n?$/)

            token(/\s+/)

            token(/<=/)      { |m| m }
            token(/=>/)      { |m| m }
            token(/[(|)]/)   { |m| m }
            token(/[\[|\]]/) { |m| m }
            token(/,/)       { |m| m }
            token(/\./)      { |m| m }

            token(/[a-zA-Z][a-zA-Z_0-9]*/) { |m| m }
            token(/[0-9]/)                 { |m| m }

            start :source_file do
                match(:code_block) { |a| a }
            end

            rule :code_block do
                match(:code_block, :statement) { |node, statement| node.add_child(statement) }
                match(:statement)              { |statement      | StatementsNode.new(statement) }
                match                          { StatementsNode.new() }
            end

            rule :statement do
                match(:component)   { |a| a }
                match(:assignment)  { |a| a }
                match(:declaration) { |a| a }
            end

            rule :component do
                match('component', :identifier, '(', :identifiers, ')', '=>', :identifiers,
                      :code_block,
                      'end') do |_, id_node, _, input_ids_node, _, _, output_ids_node, statements_node, _|
                    ComponentNode.new(id_node, input_ids_node, output_ids_node, statements_node)
                end
            end

            #
            # Declaration
            #

            rule :declaration do
                match('signal', :declarators, '<=', :expressions) do |_, ids, _, expr|
                    DeclarationNode.new(ids, expr)
                end
                match('signal', :declarators) do |_, ids|
                    DeclarationNode.new(ids, nil)
                end
            end

            rule :declarators do
                match(:declarators, ',', :declarator) { |ids, _, id| ids.add_child(id) }
                match(:declarator)                    { |id        | ListNode.new(id)  }
            end

            rule :declarator do
                match(:identifier)                    { |id_node            | DeclaratorNode.new(id_node)       }
                match(:identifier, '[', :number, ']') { |id_node, _, size, _| DeclaratorNode.new(id_node, size) }
            end

            #
            # Assignment
            #

            rule :assignment do
                match(:assignees, '<=', :expressions) do |ids, _, expr|
                    AssignNode.new(ids, expr)
                end
            end

            rule :assignees do
                match(:assignees, ',', :assignee) { |ids, _, id| ids.add_child(id) }
                match(:assignee)                  { |id        | ListNode.new(id)  }
            end

            rule :assignee do
                match(:identifier)                    { |id_node             | AssigneeNode.new(id_node)        }
                match(:identifier, '[', :number, ']') { |id_node, _, index, _| AssigneeNode.new(id_node, index) }
            end

            #
            # Expressions
            #

            rule :expressions do
                match(:expressions, ',', :expression) { |exprs, _, expr | exprs.add_child(expr) }
                match(:expression)                    { |expr           | ListNode.new(expr)    }
            end

            rule :expression do
                match(:expression_or) { |expr| expr }
            end

            rule :expression_or do
                match(:expression_or, 'or', :expression_and) do |lh, op, rh|
                    BinaryExpressionNode.new(lh, ConstantNode.new(op), rh)
                end
                match(:expression_and) { |expr| expr }
            end

            rule :expression_and do
                match(:expression_and, 'and', :expression_not) do |lh, op, rh|
                    BinaryExpressionNode.new(lh, ConstantNode.new(op), rh)
                end
                match(:expression_not) { |expr| expr }
            end

            rule :expression_not do
                match('not', :expression_not) do |op, expr|
                    UnaryExpressionNode.new(ConstantNode.new(op), expr)
                end
                match(:expression_component) { |expr| expr }
            end

            rule :expression_component do
                match(:identifier, '(', :signals, ')') do |component_id, _, inputs, _|
                    ComponentExpressionNode.new(component_id, inputs)
                end
                match(:expression_primary) { |expr| expr }
            end

            rule :expression_primary do
                match('(', :expression, ')') { |_, expr, _| expr }
                match(:signal)               { |a| a }
            end

            #
            # Signals
            #

            rule :signals do
                match(:signals, ',', :signal) { |signals, _, signal| signals.add_child(signal) }
                match(:signal)                { |signal            | ListNode.new(signal)      }
            end

            rule :signal do
                match(:number)     { |a| SignalNode.new a }
                match(:identifier) { |a| SignalNode.new a }
            end

            rule :indexed_signal do
                match(:identifier, '[', :number, ']') { |id, _, index, _| IndexedSignalNode.new(id, index) }
            end

            rule :numbers do
                match(:numbers, ',', :number) { |numbers, _, number| numbers.add_child(number) }
                match(:number)                { |number            | ListNode.new(number) }
            end

            rule :identifiers do
                match(:identifiers, ',', :identifier) { |ids, _, id| ids.add_child(id) }
                match(:identifier)                    { |id| ListNode.new(id) }
            end

            rule :identifier do
                match(/^[a-zA-Z][a-zA-Z0-9_]*$/) { |a| IdentifierNode.new a }
            end

            rule :number do
                match(/^[0-9]+$/) { |a| NumberNode.new a }
            end
        end
    end
end
