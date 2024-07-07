# frozen_string_literal: true

require_relative 'subscript'

class Reference
    attr_reader :id, :subscript

    def initialize(id, subscript)
        @id = id
        @subscript = subscript
    end

    def ==(other)
        @id == other.id && @subscript == other.subscript
    end

    def name
        return @id if @subscript == Subscript.new

        return "#{@id}[#{@subscript.start}]" if @subscript.size == 0

        "#{@id}[#{@subscript}]"
    end

    def inspect
        to_s
    end

    def to_s
        name
    end
end
