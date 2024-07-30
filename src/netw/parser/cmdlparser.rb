# frozen_string_literal: true

require_relative '../../core/parser/rdparse'
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
            token(/,/)       { |m| m }

            # Indexing
            token(/\.\./)    { |m| m }
            token(/\./)      { |m| m }

            # Subscope
            token(/::/)      { |m| m }
            token(/:/)       { |m| m }

            # Operators
            token(/=/)   { |m| m }
            token(/\|/)  { |m| m }
            token(/&/)   { |m| m }
            token(/!\|/) { |m| m }
            token(/!&/)  { |m| m }
            token(/\^/)  { |m| m }
            token(/~/)   { |m| m }
            token(/\+/)  { |m| m }
            token(/!/)   { |m| m }

            token(/[a-zA-Z][a-zA-Z_0-9]*/) { |m| m }
            token(/-?\d+/)                 { |m| m }
            token(/[01]+/)                 { |m| m }

            start :source_file do
                match(:code_block) { |root| SyntaxTree.new(RootNode.new(root)) }
            end

            rule :code_block do
                match(:statements) { |statements| CodeBlockNode.new(statements) }
                match              { CodeBlockNode.new }
            end

            rule :statements do
                match(:statements, :statement) { |statements, statement| statements.add_child(statement) }
                match(:statement)              { |statement| StatementListNode.new(statement) }
            end

            rule :statement do
                match(:component)    { |a| a }
                match(:synchronized) { |a| a }
                match(:declaration)  { |a| a }
                match(:assignment)   { |a| a }
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
                match(:component_input)                         { |input| ComponentInputListNode.new(input) }
            end

            rule :component_input do
                match(:identifier, ':', :number) { |id, _, width| ComponentInputSubscriptNode.new(id, width) }
                match(:identifier)               { |id| ComponentInputNode.new(id) }
            end

            rule :component_outputs do
                match(:component_outputs, ',', :component_output) { |outputs, _, output| outputs.add_child(output) }
                match(:component_output)                          { |output| ComponentOutputListNode.new(output) }
            end

            rule :component_output do
                match(:identifier, ':', :number) { |id, _, width| ComponentOutputSubscriptNode.new(id, width) }
                match(:identifier)               { |id|           ComponentOutputNode.new(id)                 }
            end

            #
            # Synchronized
            #

            rule :synchronized do
                match('synchronized', :synchronized_signature, :code_block, 'end') do |_, signature, statements, _|
                    SynchronizedNode.new(signature, statements)
                end
            end

            rule :synchronized_signature do
                match(:identifier, '(', :sync_identifier, ',', :synchronized_inputs, ')', '=>', :synchronized_outputs) do |id, _, clk, _, inputs, _, _, outputs|
                    SynchronizedSignatureNode.new(id, clk, inputs, outputs)
                end
            end

            rule :sync_identifier do
                match(:identifier) { |id| SynchronizedSyncNode.new(id) }
            end

            rule :synchronized_inputs do
                match(:synchronized_inputs, ',', :synchronized_input) { |inputs, _, input| inputs.add_child(input) }
                match(:synchronized_input) { |input| SynchronizedInputListNode.new(input) }
            end

            rule :synchronized_input do
                match(:identifier, ':', :number) { |id, _, width| SynchronizedInputSubscriptNode.new(id, width) }
                match(:identifier)               { |id| SynchronizedInputNode.new(id) }
            end

            rule :synchronized_outputs do
                match(:synchronized_outputs, ',', :synchronized_output) { |outputs, _, output| outputs.add_child(output) }
                match(:synchronized_output) { |output| SynchronizedOutputListNode.new(output) }
            end

            rule :synchronized_output do
                match(:identifier, ':', :number) { |id, _, width| SynchronizedOutputSubscriptNode.new(id, width) }
                match(:identifier)               { |id| SynchronizedOutputNode.new(id) }
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
                match(:declarator)                    { |id| DeclaratorListNode.new(id) }
            end

            rule :declarator do
                match(:identifier, ':', :number) { |id, _, width| DeclaratorSubscriptNode.new(id, width) }
                match(:identifier)               { |id| DeclaratorNode.new(id) }
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
                match(:receiver)                  { |id| AssignmentReceiverListNode.new(id) }
            end

            rule :receiver do
                match(:identifier, :subscript) { |id, subs| AssignmentReceiverSubscriptNode.new(id, subs) }
                match(:identifier)             { |id| AssignmentReceiverNode.new(id)                }
            end

            #
            # Expressions
            # [Ref]
            #

            rule :expressions do
                match(:expressions, ',', :expression) { |exprs, _, expr| exprs.add_child(expr) }
                match(:expression)                    { |expr| ExpressionListNode.new(expr) }
            end

            rule :expression do
                match(:expression_compare) { |expr| expr }
            end

            rule :expression_compare do
                match(:expression_compare, :operator_compare, :expression_or) do |lh, op, rh|
                    EqualsExpressionNode.new(lh, op, rh)
                end
                match(:expression_or) { |expr| expr }
            end

            rule :expression_or do
                match(:expression_or, :operator_or, :expression_and) do |lh, op, rh|
                    BinaryGateExpressionNode.new(lh, op, rh)
                end
                match(:expression_and) { |expr| expr }
            end

            rule :expression_and do
                match(:expression_and, :operator_and, :expression_nor) do |lh, op, rh|
                    BinaryGateExpressionNode.new(lh, op, rh)
                end
                match(:expression_nor) { |expr| expr }
            end

            rule :expression_nor do
                match(:expression_nor, :operator_nor, :expression_nand) do |lh, op, rh|
                    NorExpressionNode.new(lh, op, rh)
                end
                match(:expression_nand) { |expr| expr }
            end

            rule :expression_nand do
                match(:expression_nand, :operator_nand, :expression_xor) do |lh, op, rh|
                    NandExpressionNode.new(lh, op, rh)
                end
                match(:expression_xor) { |expr| expr }
            end

            rule :expression_xor do
                match(:expression_xor, :operator_xor, :expression_xnor) do |lh, op, rh|
                    XorExpressionNode.new(lh, op, rh)
                end
                match(:expression_xnor) { |expr| expr }
            end

            rule :expression_xnor do
                match(:expression_xnor, :operator_xnor, :expression_merge) do |lh, op, rh|
                    XnorExpressionNode.new(lh, op, rh)
                end
                match(:expression_merge) { |expr| expr }
            end

            rule :expression_merge do
                match(:expression_merge, :operator_merge, :expression_not) do |lh, op, rh|
                    BinaryGateExpressionNode.new(lh, op, rh)
                end
                match(:expression_not) { |expr| expr }
            end

            rule :expression_not do
                match(:operator_not, :expression_not) do |op, expr|
                    UnaryExpressionNode.new(op, expr)
                end
                match(:expression_subscript) { |expr| expr }
            end

            rule :expression_subscript do
                match(:expression_subscript, :subscript) { |expr, subs| ExpressionSubscriptNode.new(expr, subs) }
                match(:expression_component)             { |expr| expr                                    }
            end

            rule :expression_component do
                match(:component_ref, '(', :expressions, ')') do |component_id, _, inputs, _|
                    ComponentExpressionNode.new(component_id, inputs)
                end
                match(:expression_primary) { |expr| expr }
            end

            # rule :expression_when_else do
            #     match(:expression, 'when', :expression, 'else', :expression) do |primary, _, cond, _, secondary|
            #         WhenElseExpressionNode.new(primary, cond, secondary)
            #     end
            #     match(:expression_primary) { |expr| expr }
            # end

            rule :expression_primary do
                match('(', :expressions, ')') { |_, expr, _| expr }
                match(:constant)              { |const| ExpressionConstantNode.new(const) }
                match(:identifier) { |id| ExpressionIdentifierNode.new(id) }
            end

            #
            # Subscript
            # [Ref, Span]
            #

            rule :subscript do
                match('.', :span) { |_, span| span }
                match('.', :index) { |_, index| index }
            end

            rule :span do
                match(:number, ':', :number) { |start, _, stop| SpanNode.new(start, stop) }
                match(':', :number)          { |_, stop| SpanNode.new(nil, stop) }
                match(:number, ':')          { |start, _| SpanNode.new(start, nil) }
            end

            rule :index do
                match(:number) { |index| IndexNode.new(index) }
            end

            #
            # Operator
            #

            rule :operator_or do
                match('or') { |op| StringNode.new(op) }
                match('|') { |_| StringNode.new('or') }
            end

            rule :operator_and do
                match('and') { |op| StringNode.new(op) }
                match('&') { |_| StringNode.new('and') }
            end

            rule :operator_nor do
                match('nor') { |op| StringNode.new(op) }
                match('!|') { |_| StringNode.new('nor') }
            end

            rule :operator_nand do
                match('nand') { |op| StringNode.new(op) }
                match('!&') { |_| StringNode.new('nand') }
            end

            rule :operator_xor do
                match('xor') { |op| StringNode.new(op) }
                match('^') { |_| StringNode.new('xor') }
            end

            rule :operator_xnor do
                match('xnor') { |op| StringNode.new(op) }
                match('~') { |_| StringNode.new('xnor') }
            end

            rule :operator_merge do
                match('cat') { |op| StringNode.new(op) }
                match('+') { |_| StringNode.new('cat') }
            end

            rule :operator_compare do
                match('eq') { |op| StringNode.new(op) }
                match('=') { |_| StringNode.new('eq') }
            end

            rule :operator_not do
                match('not') { |op| StringNode.new(op) }
                match('!') { |_| StringNode.new('not') }
            end

            #
            # Primitives
            # [Id]
            #

            rule :component_ref do
                match(:component_ref, '::', :identifier) do |ids, _, id|
                    ids.append_id("::#{id.value}")
                    ids
                end
                match(:identifier) { |id| id }
            end

            rule :identifier_dotsep do
                match(:identifier_dotsep, '.', :identifier) do |ids, _, id|
                    ids.append_id(".#{id.value}")
                    ids
                end
                match(:identifier) { |id| id }
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
                match(:decimal)                { |num| ConstantNode.new(num) }
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
