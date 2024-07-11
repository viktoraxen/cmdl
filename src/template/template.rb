# frozen_string_literal: true

require 'colorize'

require_relative '../log/log'
require_relative '../types/declarator'
require_relative '../types/reference'
require_relative '../types/subscript'
require_relative '../error/cmdl_assert'

require_relative 'signal'
require_relative 'connection'

class Template
    attr_reader :connections, :signals, :scope

    def initialize(scope)
        @connections = {}
        @signals     = {}
        @scope       = scope
    end

    def undeclared_signals
        return [] unless @signals[:user]

        @signals[:user].filter do |name, _|
            !signal_declared? name
        end.map(&:first)
    end

    #
    # Templates
    #

    def _find_template(id)
        @scope.find_scope(id).template
    end

    def num_inputs
        return 0 if @signals[:input].nil?

        @signals[:input].size
    end

    def num_outputs
        return 1 if @signals[:output].nil?

        @signals[:output].map { |_, signal| signal.width }.sum
    end

    def inputs
        return [] if @signals[:input].nil?

        @signals[:input]
    end

    def outputs
        return [] if @signals[:output].nil?

        @signals[:output]
    end

    #
    # References
    #

    def reference(id, subscript = nil)
        [_signal_reference(id, subscript)]
    end

    def reference_add_subscript(ref, subscript)
        _signal_reference(ref.id, subscript)
    end

    #
    # Signals
    #

    def declare(declarator)
        id    = declarator.id
        width = declarator.width
        type  = declarator.type

        if _signal_exists? id
            _signal_set_width(id, width)
            _signal_declare id
        else
            _signal_add(_signal_create(id, width, declared: true), type)
        end

        _signal_reference(id)
    end

    def assign(receiver_refs, value_refs)
        receiver_refs.zip(value_refs).map do |receiver, value|
            _signal_ensure receiver.id
            _signal_ensure value.id

            connection = _connection_create('assign', [value], [receiver])
            _connection_add connection

            receiver
        end
    end

    def constant(constant)
        signal_name = constant.id.to_s
        signal_width = constant.width

        _signal_add_constant _signal_create(signal_name, signal_width, declared: true)

        [_signal_reference(signal_name)]
    end

    def _signal_create(id, width, declared: false)
        return _signal_find(id) if _signal_exists? id

        SignalTemplate.new(id, width, declared)
    end

    def _signal_add(signal, type = :user)
        @signals[type] ||= {}
        @signals[type][signal.id] = signal
    end

    def _signal_add_internal(signal)
        _signal_add(signal, :internal)
    end

    def _signal_add_constant(signal)
        _signal_add(signal, :constant)
    end

    def _signal_find(id)
        @signals.values.each { |signals| return signals[id] if signals.key? id }

        nil
    end

    def _signal_declare(id)
        return unless _signal_exists? id and not signal_declared? id

        _signal_find(id).declared = true
    end

    def _signal_ensure(id)
        return _signal_find(id) if _signal_exists? id

        input_signal = _signal_create(id, nil, declared: false)
        _signal_add input_signal
    end

    def _signal_add_connection(id, connection)
        assert_signal_exists(@scope, id)

        signal = _signal_find(id)

        return if signal.connections.include? connection

        signal.connections << connection
    end

    def _signal_set_constraint(id, connection)
        assert_signal_exists(@scope, id)

        _signal_find(id).constraint = connection
    end

    def _signal_set_width(id, width)
        assert_signal_exists(@scope, id)

        signal = _signal_find(id)

        signal.width = width
        signal.connections.each { |c| _connection_update_width c }
    end

    def signal_reference_width(ref)
        _signal_subscript_width(ref.id, ref.subscript)
    end

    def signal_width(id)
        return signal_width id.id if id.is_a? Reference
        return unless _signal_exists? id

        _signal_find(id).width
    end

    def _signal_reference(id, subscript = nil)
        Reference.new(id, subscript)
    end

    def _signal_exists?(id)
        @signals.values.map { |signals| signals.key? id }.any?
    end

    def signal_declared?(id)
        return false unless _signal_exists? id

        _signal_find(id).declared
    end

    def _signal_subscript_width(id, subscript = nil)
        return _signal_subscript_width(id.id, id.subscript) if id.is_a? Reference

        return nil unless _signal_has_width(id)

        return subscript.size if subscript.is_a? SubscriptIndex

        length = signal_width(id)
        start = subscript.start
        stop = subscript.stop
        step = subscript.step.nil? ? 1 : subscript.step

        # Magic from Gemini
        start = start.nil? ? 0      : (start < 0 ? [start + length, 0].max : start)
        stop  = stop.nil?  ? length : (stop  < 0 ? [stop  + length, 0].max : stop)

        width = if step.positive?
                    (stop - start - 1) / step
                else
                    (start - stop - 1) / -step
                end

        [0, width + 1].max.to_i
    end

    def _signal_has_width(id)
        return false unless _signal_exists? id

        !_signal_find(id).width.nil?
    end

    #
    # Connection
    #

    def _connection_create(operation, inputs, outputs, composite: false)
        return _connection_find(operation, inputs, outputs) if _connection_exists?(operation, inputs, outputs)

        connection = ConnectionTemplate.new(operation, composite)

        inputs.each do |input|
            _connection_add_input connection, input
        end

        outputs.each do |output|
            _connection_add_output connection, output
        end

        connection
    end

    def _connection_find(operation, inputs, outputs)
        @connections[operation].each do |connection|
            return connection if connection.inputs == inputs and connection.outputs == outputs
        end

        nil
    end

    def _connection_add(connection)
        @connections[connection.operation] ||= []
        @connections[connection.operation] << connection
    end

    def _connection_update_width(connection)
        return if _connection_is_composite? connection

        input_widths = connection.inputs.map do |input_ref|
            _signal_subscript_width(input_ref.id, input_ref.subscript)
        end

        return if input_widths.any?(&:nil?)

        output_width = input_widths.max

        connection.outputs.map(&:id).each { |output| _signal_set_width(output, output_width) }
    end

    def _connection_add_input(connection, input_ref)
        return if connection.inputs.include? input_ref

        connection.inputs << input_ref
        _signal_add_connection input_ref.id, connection
    end

    def _connection_add_output(connection, output_ref)
        return if connection.outputs.include? output_ref

        connection.outputs << output_ref
        _signal_set_constraint output_ref.id, connection
    end

    def _connection_is_composite?(connection)
        connection.composite
    end

    def _connection_exists?(operation, inputs, outputs)
        return false unless @connections.key? operation

        return false unless @connections[operation].map { |connection| connection.inputs == inputs }.any?

        @connections[operation].map { |connection| connection.outputs == outputs }.any?
    end

    #
    # Gates
    #

    def add_unary(operation, input_refs)
        input_refs.map do |input_ref|
            id        = input_ref.id
            subscript = input_ref.subscript

            # Ensure signal exists, otherwise created with nil width and as undeclared
            _signal_ensure(id)

            # Create output signal, same width as input
            output_name   = _gate_output_name(operation, input_ref)
            output_width  = _signal_subscript_width(id, subscript)

            output_signal = _signal_create(output_name, output_width, declared: true)

            # Add output signal to signals
            _signal_add_internal output_signal

            output_ref = _signal_reference(output_name)

            # Create connection
            connection = _connection_create(operation, [input_ref], [output_ref])
            _connection_add connection

            output_ref
        end
    end

    def add_binary(operation, lh_refs, rh_refs)
        lh_refs.zip(rh_refs).map do |lh_ref, rh_ref|
            lh_id        = lh_ref.id
            lh_subscript = lh_ref.subscript

            rh_id        = rh_ref.id
            rh_subscript = rh_ref.subscript

            # Ensure signals exist, otherwise created with nil width and as undeclared
            _signal_ensure lh_id
            _signal_ensure rh_id

            # Create output signal, same width as input
            output_name = _gate_output_name(operation, lh_ref, rh_ref)

            # Width of output can only be set if both inputs have a width
            lh_subscript_width = _signal_subscript_width(lh_id, lh_subscript)
            rh_subscript_width = _signal_subscript_width(rh_id, rh_subscript)

            output_width = nil
            output_width = lh_subscript_width unless lh_subscript_width.nil? or rh_subscript_width.nil?

            output_signal = _signal_create(output_name, output_width, declared: true)

            # Add output signal to signals
            _signal_add_internal output_signal

            output_ref = _signal_reference(output_name)

            # Create connection
            connection = _connection_create(operation, [lh_ref, rh_ref], [output_ref])
            _connection_add connection

            output_ref
        end
    end

    def add_component(id, inputs)
        # Ensure signals exist, otherwise created with nil width and as undeclared
        inputs.each do |input_ref|
            _signal_ensure input_ref.id
        end

        output_refs = _component_outputs(id, *inputs).map do |output|
            output_signal = _signal_create(output[:name], output[:width], declared: true)

            _signal_add_internal output_signal

            _signal_reference(output[:name])
        end

        # Create connection
        _connection_add _connection_create(id, inputs, output_refs, composite: true)

        output_refs
    end

    def _gate_output_name(operation, *input_refs)
        input_names = input_refs.map(&:name)

        case operation
        when 'not'
            operand = input_names.first
            # Wrap operand in parentheses if it contains a gate with lower precedence
            operand = "(#{operand})" if ['&', '|'].map { |s| operand.include? s }.any?
            return "!#{operand}"
        when 'and'
            # Wrap operands in parentheses if they contain gates with lower precedence
            operands = input_names.map { |n| n.include?('|') ? "(#{n})" : n }
            return operands.join('&')
        when 'or'
            return input_names.join('|')
        end

        assert_not_reached "Template._gate_output_name passed operation case."
    end

    def _component_outputs(id, *input_refs)
        _find_template(id).outputs.map do |name, signal|
            {
                name:  "#{id}(#{input_refs.map(&:name).join(',')}):#{name}",
                width: signal.width
            }
        end
    end

    def _component_output_names(id, *input_refs)
        _template_output_names.map do |name|
            "#{id}(#{input_refs.map(&:name).join(',')}):#{name}"
        end
    end

    def _component_output_width(id)
        template = _find_template id

        return 1 if template.nil?

        template.output_width
    end

    #
    # Debug
    #

    def print
        @signals.each do |type, signals|
            next if signals.empty?

            indent = '| ' * (depth + 1)
            text = "#{type.capitalize} signals".light_blue

            puts "#{indent}#{text}"

            width = signals.values.map(&:id).map(&:length).max

            signals.each do |name, signal|
                string = "#{name.ljust(width)}".colorize(:light_green)
                string = string.colorize(:light_yellow) if signal.id[0] =~ /[0-9]/
                string = string.colorize(:light_red) unless signal_declared? name
                puts "#{indent}| #{string} : #{signal.width}"
            end
        end

        puts '| ' * (depth + 1) unless @connections.empty?
        puts '| ' * (depth + 1) + 'Connections'.light_blue unless @connections.empty?

        type_width = @connections.keys.map(&:length).max
        inputs_widths = @connections.values.map do |c| 
            c.map do |connection|
                connection.inputs.map(&:name).join(', ').length
            end
        end

        inputs_width = inputs_widths.flatten.max

        @connections.each do |operation, connections|
            next if connections.empty?

            connections.each do |connection|
                operation = connection.operation.ljust(type_width).cyan
                inputs    = connection.inputs.map(&:name).join(', ').ljust(inputs_width).magenta
                outputs   = connection.outputs.map(&:name).join(', ').light_yellow

                string = "#{operation} : #{inputs} -> #{outputs}"
                puts "#{'| ' * (depth + 1)}| #{string}"
            end
        end
    end

    def depth
        @scope.depth
    end

    def full_name
        @scope.full_name
    end
end
