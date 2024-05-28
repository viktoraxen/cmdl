# frozen_string_literal: true

require 'colorize'
require_relative 'blueprint'

class Scope
    attr_reader :name, :blueprint

    def initialize(name, parent_scope = nil)
        @name         = name
        @parent_scope = parent_scope
        @subscopes    = {}
        @blueprint    = Blueprint.new(self)
    end

    def add_subscope(name)
        if @subscopes.include?(name)
            raise ArgumentError, "Component #{name} already exists"
        end

        @subscopes[name] = Scope.new(name, self)
    end

    def full_name
        if @parent_scope
            "#{@parent_scope.full_name}.#{@name}"
        else
            @name
        end
    end

    def inspect
        to_s
    end

    def to_s
        "<Scope> #{@name}"
    end

    def print(level = 0)
        puts ('| ' * level) + @name.light_red

        @blueprint.print(level)


        @subscopes.each_value do |scope| 
            puts '| ' * (level + 1)
            scope.print(level + 1)
        end
    end
end
