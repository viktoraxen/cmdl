# frozen_string_literal: true

class Signature
    attr_reader :id, :inputs, :outputs

    def initialize(id, inputs, outputs)
        @id      = id
        @inputs  = inputs
        @outputs = outputs
    end

    def ==(other)
        @id == other.id && @inputs == other.inputs && @outputs == other.outputs
    end

    def name
        "#{@id}(#{inputs.map(&:to_s).join(',')})"
    end

    def inspect
        "<#{self.class}> #{self}"
    end

    def to_s
        name
    end
end
