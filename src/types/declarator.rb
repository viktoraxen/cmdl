# frozen_string_literal: true

class Declarator
    attr_reader :id, :width, :type

    def initialize(id, width, type: :user)
        @id    = id
        @width = width
        @type  = type
    end

    def ==(other)
        @id == other.id && @width == other.width
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
