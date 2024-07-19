# frozen_string_literal: true

require_relative 'subscript'

class Reference
    attr_reader :id

    def initialize(id, subscript = nil)
        @id = id
        @subscript = subscript
        @subscript ||= SubscriptRange.new
    end

    def ==(other)
        @id == other.id && @subscript == other.subscript
    end

    def subscript
        return SubscriptRange.new if @subscript.nil?

        @subscript
    end

    def name
        return @id if @subscript == SubscriptRange.new

        return "#{@id}.#{@subscript.start}" if @subscript.size == 0

        "#{@id}.#{@subscript}"
    end

    def inspect
        to_s
    end

    def to_s
        name
    end
end
