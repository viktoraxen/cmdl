# frozen_string_literal: true

require_relative '../log/log'
require_relative '../scope'

class ASTNode
    attr_accessor :value, :children, :parent

    def initialize(*children, value: nil)
        @value    = value
        @children = children
        @parent   = nil
        @children.each { |child| child&.parent = self }
    end

    def add_child(child)
        @children << child
        child.parent = self
    end

    def root?
        @parent.nil?
    end

    def depth
        return 0 if root?

        @parent.depth + 1
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

    def debug_log(*msg)
        msg = *@children.map(&:to_s) if msg.empty?

        Log.debug "#{' ' * depth}#{self.class}:", *msg
    end

    def leaf?
        @children.empty?
    end

    def inspect
        "<#{self.class}: Children: #{@children.size}>"
    end

    def to_s
        self.class.to_s
    end

    def print
        puts ('|  ' * depth) + to_s

        puts ('|  ' * (depth + 1)) + @value.to_s if leaf?

        children.each { |child| child&.print }
    end

    def evaluate(*)
        raise NotImplementedError("Evaluate not implemented for #{self.class} with value #{@value} and children #{@children}")
    end
end

class LeafNode < ASTNode
    def debug_log(msg = nil)
        super(@value.to_s) if msg.nil?
        super(msg) unless msg.nil?
    end

    def initialize(value)
        super(value: value)
    end

    def evaluate(*)
        debug_log

        @value
    end
end

class ListNode < ASTNode
    def debug_log(msg = nil)
        super(@children.map(&:to_s)) if msg.nil?
        super unless msg.nil?
    end

    def evaluate(*args)
        debug_log

        @children.map { |child| child.evaluate(*args) }
    end
end

class FlatListNode < ASTNode
    def declare(*args)
        debug_log

        @children.map { |child| child.declare(*args) }.flatten
    end

    def evaluate(*args)
        debug_log

        @children.map { |child| child.evaluate(*args) }.flatten
    end
end

class ScopeNode < ASTNode
end
