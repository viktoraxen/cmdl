# frozen_string_literal: true

require_relative '../../core/error/cmdl_assert'

require_relative 'nodes'

class SyntaxTree
    def initialize(root)
        @root = root
    end

    def evaluate
        root_scope = scope_structure(@root)

        @root.evaluate(root_scope)
    end

    def scope_structure(node)
        assert_valid_scope_node(node)

        signature = node.children.find { |child| child.is_a?(SignatureNode) }&.evaluate

        scope = Scope.new signature&.id

        scope.template.make_synchronized if node.is_a? SynchronizedNode

        signature&.inputs&.each do |input|
            scope.template.declare(input)
        end

        signature&.outputs&.each do |output|
            scope.template.declare(output)
        end

        sync = signature&.sync

        scope.template.declare(sync) unless sync.nil?

        code_node = node.children.find { |child| child.is_a?(CodeBlockNode) }

        code_node.scope_nodes.each do |child|
            subscope_structure = scope_structure(child)

            assert_valid_subscope(scope, subscope_structure)

            scope.add_subscope(subscope_structure)
        end

        scope
    end

    def print
        @root.print
    end
end
