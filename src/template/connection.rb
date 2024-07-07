# frozen_string_literal: true

class ConnectionTemplate
    attr_reader :operation, :composite
    attr_accessor :inputs, :outputs

    def initialize(operation, composite)
        @operation = operation
        @inputs    = []
        @outputs   = []
        @composite = composite
    end

    def name 
        "#{operation}(#{inputs.map(&:name).join(',')})->#{outputs.map(&:name).join(',')}"
    end

    def ==(other)
        @operation == other.operation && @inputs == other.inputs && @outputs == other.outputs
    end

    def inspect
        to_s
    end

    def to_s
        "<#{self.class}> #{operation}(#{inputs.map(&:id).join(',')})"
    end
end
