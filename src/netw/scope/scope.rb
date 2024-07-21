# frozen_string_literal: true

require 'colorize'
require_relative '../template/template'

class Scope
    attr_reader :id, :template, :subscopes
    attr_accessor :parent_scope

    def initialize(id, parent_scope = nil)
        @id           = id.nil? ? 'Network' : id
        @parent_scope = parent_scope
        @subscopes    = {}
        @template     = Template.new(self)
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

        top_level = id.split('::').first
        deep_levels = id.split('::')[1..].join('::')

        return @subscopes[top_level]._find_scope_down(deep_levels) if @subscopes.key? top_level

        nil
    end

    def contains_scope?(id)
        @subscopes.key? id
    end

    def full_name
        return "#{@parent_scope.full_name}::#{@id}" if @parent_scope

        @id
    end

    def inspect
        to_s
    end

    def to_s
        "<#{self.class}> #{@id}"
    end

    def root?
        depth.zero?
    end

    def depth
        return 0 if @parent_scope.nil?

        @parent_scope.depth + 1
    end

    def print(pf = '', final = true)
        puts "#{pf}#{leaf(final)}#{@id.light_red}"

        new_pf = root? ? '' : "#{pf}#{base(final)}"
        @template.print(new_pf, final, !@subscopes.empty?)

        @subscopes.each_with_index do |(_, scope), index|
            puts "#{pf}#{new_line(final)}"
            scope.print(new_pf, index == @subscopes.size - 1)
        end
    end

    def new_line(final = false)
        "#{base(final)}│"
    end

    def leaf(final = false)
        if root?
            ''
        else
            (final ? '└─ ' : '├─ ')
        end
    end

    def base(final = false)
        if root?
            ''
        else
            (final ? '   ' : '│  ')
        end
    end
end
