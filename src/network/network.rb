# frozen_string_literal: true

require 'colorize'

require_relative '../template/template'
require_relative '../error/cmdl_assert'
require_relative 'constraint'

class Network
    attr_accessor :parent

    def initialize(name)
        @name        = name
        @parent      = nil
        reset
    end

    def reset
        @wires       = {}
        @constraints = {}
        @subnetworks = {}
    end

    def inputs
        @wires[:input].map { |_, wires| wires }
    end

    def outputs
        @wires[:output].map { |_, wires| wires }
    end

    def synthesize_scope(scope)
        assert_valid_scope scope

        template = scope.template

        reset

        template.signals.each do |type, signals|
            @wires[type] ||= {}

            signals.each do |name, signal|
                wires = _wires_create(signal)

                if type == :constant
                    value = signal.id.split('x').first.to_i

                    value_string = value.to_s(2).rjust(signal.width, '0')

                    value_string.chars.reverse[...signal.width].each_with_index do |bit, i|
                        wires[i].value = bit == '1'
                    end
                end

                @wires[type][name] = wires
            end
        end

        template.connections.each_value do |connections|
            connections.each do |connection|
                if _connection_is_gate?(connection)
                    _gate_add(connection)
                else
                    _connection_add(connection, scope)
                end
            end
        end

        self
    end

    def _wires_create(signal)
        (0...signal.width).map do |i|
            wire_name = "#{signal.id}[#{i}]"
            Wire.new(wire_name)
        end
    end

    def _connection_add(connection, scope)
        # Connection validity is assumed to have been checked when evaluating syntaxtree

        component_scope = scope.find_scope(connection.operation)

        assert_valid_scope component_scope

        network_name = _network_name(connection)
        network = Network.new(network_name)

        network.synthesize_scope(component_scope)

        @subnetworks[network_name] = network

        input_wires = connection.inputs.map do |reference|
            _get_wires_by_reference(reference)
        end

        output_wires = connection.outputs.map do |reference|
            _get_wires_by_reference(reference)
        end

        network_inputs = network.inputs
        network_outputs = network.outputs

        input_wires.zip(network_inputs).each do |input, network_input|
            input.zip(network_input).each do |input_wire, network_input_wire|
                # TODO: Add to constratints list
                AssignGate.new('Connection input', input_wire, network_input_wire)
            end
        end

        output_wires.zip(network_outputs).each do |output, network_output|
            output.zip(network_output).each do |output_wire, network_output_wire|
                # TODO: Add to constratints list
                AssignGate.new('Connection output', network_output_wire, output_wire)
            end
        end

        _add_subnetwork(network_name, network)
    end

    def _add_subnetwork(name, network)
        @subnetworks[name] = network
        network.parent = self
    end

    def _constraint_name(operation, inputs, output)
        "#{operation}(#{inputs.map(&:name).join(',')})->#{output.name}"
    end

    def _network_name(connection)
        "#{connection.operation}(#{connection.inputs.join(', ')})"
    end

    def _gate_add(connection)
        if _gate_is_unary? connection
            _gate_add_unary(connection)
        elsif _gate_is_binary? connection
            _gate_add_binary(connection)
        elsif _gate_is_merge? connection
            _gate_add_merge(connection)
        else
            assert_not_reached "Network._gate_add: Invalid gate operation: #{connection.operation}"
        end
    end

    def _gate_add_unary(connection)
        assert_valid_unary_gate(connection)

        inputs = _gate_inputs_unary(connection)
        outputs = _gate_outputs(connection)

        inputs.zip(outputs).each do |input, output|
            # TODO: Add to constraints list

            case connection.operation
            when 'not'
                NotGate.new(connection.name, input, output)
            when 'assign'
                AssignGate.new(connection.name, input, output)
            else
                assert_not_reached "Network._gate_add_unary: Invalid unary gate operation: #{connection.operation}"
            end
        end
    end

    def _gate_add_binary(connection)
        assert_valid_binary_gate(connection)

        inputs = _gate_inputs_binary(connection)
        outputs = _gate_outputs(connection)

        inputs.zip(outputs).each do |(lh, rh), output|
            # TODO: Add to constraints list

            case connection.operation
            when 'and'
                AndGate.new(connection.name, lh, rh, output)
            when 'or'
                OrGate.new(connection.name, lh, rh, output)
            else
                assert_not_reached "Network._gate_add_binary: Invalid binary gate operation: #{connection.operation}"
            end
        end
    end

    def _gate_add_merge(connection)
        assert_valid_merge_gate(connection)

        inputs = _gate_inputs_merge(connection)
        outputs = _gate_outputs(connection)

        inputs.zip(outputs).each do |input, output|
            AssignGate.new(connection.name, input, output)
        end
    end

    def _gate_inputs_unary(connection)
        connection.inputs.map do |reference|
            _get_wires_by_reference(reference)
        end.flatten
    end

    def _gate_inputs_binary(connection)
        lh_inputs = _get_wires_by_reference(connection.inputs[0])
        rh_inputs = _get_wires_by_reference(connection.inputs[1])

        lh_inputs.zip(rh_inputs)
    end

    def _gate_inputs_merge(connection)
        # Reverse to make behaviour more intuitive
        connection.inputs.reverse.map do |reference|
            _get_wires_by_reference(reference)
        end.flatten
    end

    def _gate_outputs(connection)
        connection.outputs.map do |reference|
            _get_wires_by_reference(reference)
        end.flatten
    end

    def _gate_is_unary?(connection)
        ['not', 'assign'].include? connection.operation
    end

    def _gate_is_binary?(connection)
        ['and', 'or'].include? connection.operation
    end

    def _gate_is_merge?(connection)
        ['cat'].include? connection.operation
    end

    def _connection_is_gate?(connection)
        _gate_is_unary?(connection) || _gate_is_binary?(connection) || _gate_is_merge?(connection)
    end

    def _get_wires_by_reference(reference)
        wires = _get_wires_by_name(reference.id)

        return wires[reference.subscript.start..] if reference.subscript.right_sided?

        wires[reference.subscript.as_range]
    end

    def _get_wires_by_name(name)
        @wires.each_value do |wires|
            return wires[name] if wires.key?(name)
        end

        []
    end

    def _signals_state
        state = { name: @name }

        %i[input output user].each do |sym|
            @wires[sym]&.each do |name, wires|
                value = wires.reverse.map(&:value_b).join
                state[name] = value
            end
        end

        state
    end

    def state
        state = _signals_state

        @subnetworks.each do |name, network|
            state[name] = network.state
        end

        state
    end

    def depth
        return 0 if @parent.nil?

        @parent.depth + 1
    end

    def print(full_print = false, deep_print = false, pf = '', final = true)
        puts "#{pf}#{root? ? '' : leaf(final)}#{@name.light_red}"
        pf = root? ? '' : "#{pf}#{base(final)}"

        wires_to_print = @wires
        wires_to_print = wires_to_print.except(:internal, :constant) unless full_print

        wires_to_print.each_with_index do |(type, wires), index|
            next if wires.empty?

            final_type = index == wires_to_print.size - 1 && (!deep_print || @subnetworks.empty?)
            text = "#{type.capitalize} wires".light_blue

            puts "#{pf}#{type_indent(final_type)}#{text}"

            width = wires.keys.map(&:length).max

            wires.each_with_index do |(name, wire), index|
                string = name.ljust(width).to_s.colorize(:light_green)
                string = string.colorize(:light_yellow) if name[0] =~ /[0-9]/

                binary_values = wire.reverse.map(&:value_b)
                string += " : #{binary_values.join(' ')}"

                decimal_value = binary_values.join.to_i(2) unless binary_values.map { |b| b == '<nil>' }.any?
                string += " : #{decimal_value.to_s.cyan}" if decimal_value

                final_sig = index == wires.size - 1
                indent = element_indent(final_sig, final_type)

                puts "#{pf}#{indent}#{string}"
            end
        end

        return unless deep_print

        @subnetworks.values.each_with_index do |network, index|
            puts "#{pf}#{new_line(final)}"

            network.print(full_print, deep_print, pf, index == @subnetworks.size - 1)
        end
    end

    def element_indent(final = false, final_type = false)
        base(final_type) + leaf(final)
    end

    def type_indent(final = false)
        leaf(final)
    end

    def new_line
        '│'
    end

    def leaf(final = false)
        final ? '└─ ' : '├─ '
    end

    def base(final = false)
        final ? '   ' : '│  '
    end

    def root?
        depth == 0
    end

    def inspect
        to_s
    end
end
