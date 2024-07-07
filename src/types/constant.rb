# frozen_string_literal: true

class Constant
    attr_reader :value, :width

    def initialize(value, width = nil)
        @value = value
        @width = width
        @width = Math.log2(value).clamp((1..)).ceil if width.nil?
    end

    def ==(other)
        @value == other.value && @width == other.width
    end

    def name
        id
    end

    def id
        to_s
    end

    def inspect
        to_s
    end

    def to_s
        "#{@value}:#{@width}"
    end
end
