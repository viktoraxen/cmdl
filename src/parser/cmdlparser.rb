# frozen_string_literal: true

require_relative 'rdparse'
require_relative '../syntaxtree/syntaxtree'

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
            token(/\.\./)    { |m| m }
            token(/\./)      { |m| m }
            token(/::/)       { |m| m }
            token(/:/)       { |m| m }

            token(/[a-zA-Z][a-zA-Z_0-9]*/) { |m| m }
            token(/-?\d+/)                 { |m| m }
            token(/[01]+/)                 { |m| m }

            start :source_file do
                match(:code_block) { |root| SyntaxTree.new(RootNode.new(root)) }
            end

            rule :code_block do
                # match(:code_block, :statement) { |node, statement| node.add_child(statement) }
                # match(:statement)              { |statement      | CodeBlockNode.new(statement) }
                match(:statements) { |statements| CodeBlockNode.new(statements) }
                match              { CodeBlockNode.new() }
            end

            rule :statements do
                match(:statements, :statement) { |statements, statement| statements.add_child(statement) }
                match(:statement)              { |statement              | StatementListNode.new(statement) }
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
                match(:component_input)                         { |input           | ComponentInputListNode.new(input) }
            end

            rule :component_input do
                match(:identifier, ':', :number) { |id, _, width| ComponentInputSubscriptNode.new(id, width) }
                match(:identifier)               { |id          | ComponentInputNode.new(id)                 }
            end

            rule :component_outputs do
                match(:component_outputs, ',', :component_output) { |outputs, _, output| outputs.add_child(output) }
                match(:component_output)                          { |output            | ComponentOutputListNode.new(output) }
            end

            rule :component_output do
                match(:identifier, ':', :number) { |id, _, width| ComponentOutputSubscriptNode.new(id, width) }
                match(:identifier)               { |id|           ComponentOutputNode.new(id)                 }
            end

            #
            # Declaration
            # [Decl] <= [Ref]
            # [Decl]
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
                match(:identifier, ':', :number) { |id, _, width| DeclaratorSubscriptNode.new(id, width) }
                match(:identifier)               { |id          | DeclaratorNode.new(id)             }
            end

            #
            # Assignment
            # [Ref] <= [Ref]
            #

            rule :assignment do
                match(:receivers, '<=', :expressions) do |ids, _, expr|
                    AssignNode.new(ids, expr)
                end
            end

            rule :receivers do
                match(:receivers, ',', :receiver) { |ids, _, id| ids.add_child(id) }
                match(:receiver)                  { |id        | AssignmentReceiverListNode.new(id)  }
            end

            rule :receiver do
                match(:identifier, :subscript) { |id, subs| AssignmentReceiverSubscriptNode.new(id, subs) }
                match(:identifier)             { |id      | AssignmentReceiverNode.new(id)                }
            end

            #
            # Expressions
            # [Ref]
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
                    BinaryExpressionNode.new(lh, StringNode.new(op), rh)
                end
                match(:expression_and) { |expr| expr }
            end

            rule :expression_and do
                match(:expression_and, 'and', :expression_not) do |lh, op, rh|
                    BinaryExpressionNode.new(lh, StringNode.new(op), rh)
                end
                match(:expression_not) { |expr| expr }
            end

            rule :expression_not do
                match('not', :expression_not) do |op, expr|
                    UnaryExpressionNode.new(StringNode.new(op), expr)
                end
                match(:expression_subscript) { |expr| expr }
            end

            rule :expression_subscript do
                match(:expression_subscript, :subscript) { |expr, subs| ExpressionSubscriptNode.new(expr, subs) }
                match(:expression_component)             { |expr      | expr                                    }
            end

            rule :expression_component do
                match(:component_ref, '(', :expressions, ')') do |component_id, _, inputs, _|
                    ComponentExpressionNode.new(component_id, inputs)
                end
                match(:expression_primary) { |expr| expr }
            end

            rule :expression_primary do
                match('(', :expressions, ')') { |_, expr, _| expr                              }
                match(:constant)              { |const     | ExpressionConstantNode.new(const) }
                match(:identifier)            { |id        | ExpressionIdentifierNode.new(id)  }
            end

            #
            # Subscript
            # [Ref, Span]
            #
            
            rule :subscript do
                match('.', :span,) { |_, span | span  }
                match('.', :index) { |_, index| index }
            end

            rule :span do
                match(:number, ':', :number) { |start, _, stop| SpanNode.new(start, stop) }
                match(':', :number)          { |_, stop       | SpanNode.new(nil,   stop) }
                match(:number, ':')          { |start, _      | SpanNode.new(start, nil)  }
            end

            rule :index do
                match(:number) { |index| IndexNode.new(index) }
            end

            #
            # Primitives
            # [Id]
            #
            
            rule :component_ref do
                match(:component_ref, '::', :identifier) { |ids, _, id| ids.append_id("::#{id.value}"); ids }
                match(:identifier)                       { |id        | id }
            end

            rule :identifier_dotsep do
                match(:identifier_dotsep, '.', :identifier) { |ids, _, id| ids.append_id(".#{id.value}"); ids }
                match(:identifier)                          { |id        | id }
            end

            rule :identifiers do
                match(:identifiers, ',', :identifier) { |ids, _, id| ids.add_child(id) }
                match(:identifier)                    { |id| IdentifierListNode.new(id) }
            end

            rule :identifier do
                match(/^[a-zA-Z][a-zA-Z0-9_]*$/) { |a| IdentifierNode.new(a) }
            end

            rule :constant do
                match(:decimal, ':', :decimal) { |num, _, width| ConstantSubscriptNode.new(num, width) }
                match(:decimal)                { |num          | ConstantNode.new(num)                 }
            end

            rule :number do
                match(:decimal) { |a| a }
            end

            rule :binary do
                match('b', /[01]+/) { |number| BinaryNumberNode.new(number) }
            end

            rule :decimal do
                match(/-?\d+/) { |a| NumberNode.new(a) }
            end
        end
    end
end
