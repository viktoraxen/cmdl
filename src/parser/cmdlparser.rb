# frozen_string_literal: true

require_relative 'rdparse'
require_relative '../nodes/nodes'

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
            token(/:/)      { |m| m }

            token(/[a-zA-Z][a-zA-Z_0-9]*/) { |m| m }
            token(/[0-9]+/)                { |m| m }

            start :source_file do
                match(:code_block) { |a| a }
            end

            rule :code_block do
                match(:code_block, :statement) { |node, statement| node.add_child(statement) }
                match(:statement)              { |statement      | CodeBlockNode.new(statement) }
                match                          { CodeBlockNode.new() }
            end

            rule :statement do
                match(:component)   { |a| a }
                match(:assignment)  { |a| a }
                match(:declaration) { |a| a }
            end

            #
            # Component
            #

            rule :component do
                match('component', :component_signature, :code_block, 'end') do |_, signature, statements_node, _|
                    ComponentNode.new(signature, statements_node)
                end
            end

            rule :component_signature do
                match(:identifier, '(', :component_inputs, ')', '=>', :component_outputs) do |id, _, inputs, _, _, outputs|
                    ComponentSignatureNode.new(id, inputs, outputs)
                end
            end

            rule :component_inputs do
                match(:component_inputs, ',', :component_input) { |inputs, _, input| inputs.add_child(input) }
                match(:component_input)                         { |input            | ComponentInputListNode.new(input) }
            end

            rule :component_input do
                match(:subscript)  { |a| a }
                match(:identifier) { |a| a }
            end

            rule :component_outputs do
                match(:component_outputs, ',', :component_output) { |outputs, _, output| outputs.add_child(output) }
                match(:component_output)                          { |output            | ComponentOutputListNode.new(output) }
            end

            rule :component_output do
                match(:subscript)  { |a| a }
                match(:identifier) { |a| a }
            end

            #
            # Declaration
            # [Id] <= [Id]
            # [Id]
            #

            rule :declaration do
                match('signal', :declarators, '<=', :expressions) do |_, decl, _, expr|
                    DeclarationNode.new(decl, expr)
                end
                match('signal', :declarators) do |_, decl|
                    DeclarationNode.new(decl, nil)
                end
            end

            rule :declarators do
                match(:declarators, ',', :declarator) { |ids, _, id| ids.add_child(id) }
                match(:declarator)                    { |id        | DeclaratorListNode.new(id)  }
            end

            rule :declarator do
                match(:subscript)  { |a| a }
                match(:identifier) { |a| a }
            end

            #
            # Assignment
            # [Id] <= [Id]
            #

            rule :assignment do
                match(:assignees, '<=', :expressions) do |ids, _, expr|
                    AssignNode.new(ids, expr)
                end
            end

            rule :assignees do
                match(:assignees, ',', :assignee) { |ids, _, id| ids.add_child(id) }
                match(:assignee)                  { |id        | AssigneeListNode.new(id)  }
            end

            rule :assignee do
                match(:subscript)  { |a| a }
                match(:identifier) { |a| a }
            end

            #
            # Expressions
            # [Id]
            #

            rule :expressions do
                match(:expressions, ',', :expression) { |exprs, _, expr | exprs.add_child(expr) }
                match(:expression)                    { |expr           | ExpressionListNode.new(expr)    }
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
                match(:identifier, '(', :expressions, ')') do |component_id, _, inputs, _|
                    ComponentExpressionNode.new(component_id, inputs)
                end
                match(:expression_primary) { |expr| expr }
            end

            rule :expression_primary do
                match('(', :expression, ')') { |_, expr, _| expr }
                match(:subscript)            { |a| a }
                match(:identifier)           { |a| a }
                match(:number)               { |a| a }
            end

            #
            # Subscript
            # [Id, Span]
            #
            
            rule :subscript do
                match(:identifier, '[', :span,  ']') { |id, _, span, _ | SubscriptSpanNode.new(id, span)  }
                match(:identifier, '[', :index, ']') { |id, _, index, _| SubscriptIndexNode.new(id, index) }
            end

            rule :span do
                match(:number, ':', :number) { |start, _, stop| SpanNode.new(start,             stop)               }
                match(':', :number)          { |_, stop       | SpanNode.new(NumberNode.new(0), stop)               }
                match(:number, ':')          { |start, _      | SpanNode.new(start,             NumberNode.new(-1)) }
            end

            rule :index do
                match(:number) { |index| IndexNode.new(index) }
            end

            #
            # Primitives
            # [Id]
            #

            rule :identifiers do
                match(:identifiers, ',', :identifier) { |ids, _, id| ids.add_child(id) }
                match(:identifier)                    { |id| IdentifierListNode.new(id) }
            end

            rule :identifier do
                match(/^[a-zA-Z][a-zA-Z0-9_]*$/) { |a| IdentifierNode.new(a) }
            end

            rule :numbers do
                match(:numbers, ',', :number) { |numbers, _, number| numbers.add_child(number) }
                match(:number)                { |number            | NumberListNode.new(number) }
            end

            rule :number do
                match(/^[0-9]+$/) { |a| NumberNode.new(a) }
            end
        end
    end
end
