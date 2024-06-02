# frozen_string_literal: true

require_relative 'nodes_core'

class CodeBlockNode < Node
    def evaluate(scope, *)
        Log.debug 'StatementsNode.evaluate:', @children.to_s

        @children.each do |child|
            Log.debug ''
            child.evaluate(scope)
        end

        scope.blueprint.cleanup

        undeclared_wires = scope.blueprint.undeclared_wires

        raise UndeclaredSignalsException.new(undeclared_wires, scope) unless undeclared_wires.empty?

        scope
    end
end
