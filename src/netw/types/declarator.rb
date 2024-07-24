# frozen_string_literal: true

class Declarator
    attr_reader :id, :width
    attr_accessor :type

    def initialize(id, width, type: nil)
        @id    = id
        @width = width
        @type  = type || :user
    end

    def ==(other)
        @id == other.id && @width == other.width
    end

    def type=(value)
        @type = value
        self
    end

    def inspect
        to_s
    end

    def to_s
        s = "#{id}[#{width}]"
        s + " : #{@type}" if @type != :user
        s
    end
end
