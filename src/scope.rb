# frozen_string_literal: true

require 'colorize'
require_relative 'template/template'

class Scope
    attr_reader :id, :template, :subscopes
    attr_accessor :parent_scope

    def initialize(id, parent_scope = nil)
        @id         = id.nil? ? 'Network' : id
        @parent_scope = parent_scope
        @subscopes    = {}
        @template     = Template.new(self)
        # @networks     = {}
    end

    def synthesize
        network = Network.new(full_name)
        network.synthesize_scope(self)
    end

    def add_subscope(scope)
        scope.parent_scope = self
        @subscopes[scope.id] = scope
    end

    def find_scope(id)
        scope = _find_scope_down(id)

        return scope unless scope.nil?

        @parent_scope&.find_scope(id)
    end

    def _find_scope_down(id)
        return self if id == ''

        top_level = id.split('.').first
        deep_levels = id.split('.')[1..].join('.')

        return @subscopes[top_level]._find_scope_down(deep_levels) if @subscopes.key? top_level

        nil
    end

    def contains_scope?(id)
        @subscopes.key? id
    end

    def full_name
        return "#{@parent_scope.full_name}.#{@id}" if @parent_scope

        @id
    end

    def inspect
        to_s
    end

    def to_s
        "<#{self.class}> #{@id}"
    end

    def depth
        return 0 if @parent_scope.nil?

        @parent_scope.depth + 1
    end

    def print
        puts ('| ' * depth) + @id.light_red

        @template.print

        @subscopes.each_value do |scope| 
            puts '| ' * (depth + 1)
            scope.print
        end
    end
end
