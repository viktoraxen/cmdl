# frozen_string_literal: true

# !/usr/bin/env ruby

require_relative '../../../core/error/cmdl_assert'

class Constraint
    attr_reader :name, :outputs, :inputs

    def initialize(name, inputs, output)
        @name = name
        @inputs = inputs
        @inputs.each { |input| input.add_connection(self) }
        @output = output
        @output.add_constraint(self)

        @type = 'constraint'
    end

    def new_value(queue = nil)
        unless determined?
            @output.value = nil unless @output.value.nil?
            return
        end

        assert_valid_gate_operation(@operation)

        @output.set_value(@operation.call, queue)
    end

    def ==(other)
        type_s == other.type_s and @inputs == other.inputs and @output == other.output
    end

    def determined?
        @inputs.all? { |input| !input.value.nil? }
    end

    def to_s
        "#{type_s}: #{@inputs.map(&:name).join(', ')} -> #{@output.name}"
    end

    def type_s
        @type
    end

    def expression
        raise NotImplementedError
    end
end
