# frozen_string_literal: true

require_relative '../log/log'
require_relative '../scope'
require_relative '../cmdl_exceptions'

class Node
    attr_accessor :value, :children

    def initialize(*children, value: nil)
        @value    = value
        @children = children
    end

    def add_child(child)
        @children << child
        self
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

    def leaf?
        @children.empty?
    end

    def inspect
        "<#{self.class}: Children: #{@children.size}>"
    end

    def to_s
        self.class.to_s
    end

    def print(level = 0)
        puts ('|  ' * level) + to_s

        puts ('|  ' * (level + 1)) + @value.to_s if leaf?

        children.each { |child| child&.print(level + 1) }
    end

    def evaluate(*)
        raise NotImplementedError("Evaluate not implemented for #{self.class} with value #{@value} and children #{@children}")
    end
end

class LeafNode < Node
    def initialize(value)
        super(value: value)
    end

    def evaluate(*)
        Log.debug "#{self.class}.evaluate:", @value.to_s

        @value
    end
end

class FlatListNode < Node
    def evaluate(*args)
        Log.debug 'FlatListNode.evaluate:', @children.to_s

        @children.map { |child| child.evaluate(*args) }.flatten
    end
end

class ListNode < Node
    def evaluate(*args)
        Log.debug 'ListNode.evaluate:', @children.to_s

        @children.map { |child| child.evaluate(*args) }
    end
end
