# frozen_string_literal: true

class SignalTemplate
    attr_reader :id
    attr_accessor :declared, :connections, :constraint, :width

    def initialize(id, width, declared)
        @id          = id
        @width       = width
        @declared    = declared
        @connections = []
        @constraint  = nil
    end

    def inspect
        to_s
    end

    def to_s
        "<#{self.class}> #{id}[#{width}]"
    end
end
