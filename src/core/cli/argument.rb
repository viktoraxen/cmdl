# frozen_string_literal: true

class CliArgument
    attr_reader :name, :description

    def initialize(name, description)
        @name        = name
        @description = description
        freeze
    end

    def width
        @name.length
    end

    def symbol
        @name.to_sym
    end

    def to_s(width = 0)
        @name.ljust(width) + "  #{@description}"
    end
end
