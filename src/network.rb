# frozen_string_literal: true

require_relative 'blueprint'
require_relative 'constraint'

class InvalidConnectionException < StandardError
end

class Network
    def Network.create_network(root_scope, name_suffix = '')
        network = Network.new("#{root_scope.full_name}#{name_suffix}")
        blueprint = root_scope.blueprint

        blueprint.wires.each do |type, wires|
            wires.each do |wire|
                network.add_wire(type, wire.name)
            end
        end

        blueprint.connections.each do |type, connections|
            if ['and', 'or', 'not', 'direct'].include? type
                connections.each do |connection|
                    network.add_constraint(connection)
                end
            else
                scope = root_scope.find_scope(type)

                connections.each do |connection|
                    subnetwork = create_network(scope, "(#{connection.inputs.map(&:name).join(',')})")
                    network.add_subnetwork(connection, subnetwork)
                end
            end
        end

        network.set_VCC
        network.set_GND

        network
    end

    attr_reader :name
    attr_accessor :wires

    def initialize(name)
        @name         = name
        @wires        = {}
        @constraints  = {}
        @subnetworks  = {}
    end

    def add_subnetwork(connection, network)
        check_connection(connection)

        @subnetworks[network.name] = network

        outside_input_wires = connection.inputs.map { |w| find_wire(w.name) }
        outside_output_wires = connection.outputs.map { |w| find_wire(w.name) }

        network_input_wires = network.input_wires
        network_output_wires = network.output_wires

        input_gate_name = "input:#{connection.type}(#{outside_input_wires.map(&:name).join(',')})"

        @constraints[input_gate_name] = FanGate.new(input_gate_name, outside_input_wires, network_input_wires)

        output_gate_name = "output:#{connection.type}(#{network_output_wires.map(&:name).join(',')})"

        @constraints[output_gate_name] = FanGate.new(output_gate_name, network_output_wires, outside_output_wires)

        network
    end

    def add_constraint(connection)
        check_connection(connection)

        name    = connection.name
        type    = connection.type
        inputs  = connection.inputs.map { |i| find_wire(i.name) }
        outputs = connection.outputs.map { |o| find_wire(o.name) }

        case type
        when 'and'
            @constraints[name] = AndGate.new(name, inputs, outputs)
        when 'or'
            @constraints[name] = OrGate.new(name, inputs, outputs)
        when 'not'
            @constraints[name] = NotGate.new(name, inputs, outputs)
        when 'direct'
            @constraints[name] = FanGate.new(name, inputs, outputs)
        end

        connection
    end

    def add_wire(type, name)
        @wires[type] ||= {}

        @wires[type][name] = Wire.new(name)
    end

    def find_wire(name)
        @wires.each do |_, wires|
            return wires[name] if wires.key? name
        end

        nil
    end

    def input_wires
        @wires['input'].values
    end

    def output_wires
        @wires['output'].values
    end

    def set_VCC
        @wires['internal']['VCC']&.value = true
    end

    def set_GND
        @wires['internal']['GND']&.value = false
    end

    def print(level = 0, print_all: true)
        puts ('| ' * level) + @name.cyan

        @wires.each do |type, wires|
            next if wires.empty? or type == 'internal'

            text = "#{type.capitalize} wires".magenta

            puts "#{'| ' * (level + 1)}#{text}"

            width = wires.keys.map(&:length).max

            wires.each do |name, wire|
                name_string = "#{name}:".ljust(width + 1)
                value_string = wire.value.to_s.colorize(wire.value ? :green : :red)
                if wire.value == '<nil>'
                    value_string = value_string.colorize(:yellow)
                end
                
                puts "#{'| ' * (level + 2)}#{name_string} #{value_string}"
            end
        end

        return unless print_all

        @subnetworks.each_value do |network|
            puts '| ' * (level + 1)
            network.print(level + 1)
        end
    end

    def print_debug(level = 0)
        puts ('| ' * level) + @name.light_red

        puts ('| ' * (level + 1)) + 'Constraints'.light_blue

        @constraints.each do |name, constraint|
            inputs = constraint.inputs.map(&:name).join(', ')
            outputs = constraint.outputs.map(&:name).join(', ')
            puts "#{'| ' * (level + 2)}#{name}: #{inputs} -> #{outputs}"
        end

        puts '| ' * (level + 1) unless @wires.empty?

        @wires.each do |type, wires|
            next if wires.empty?

            text = "#{type.capitalize} wires".light_blue

            puts "#{'| ' * (level + 1)}#{text}"

            wires.each do |name, wire|
                puts "#{'| ' * (level + 2)}#{name}: #{wire.value}"
            end
        end

        @subnetworks.each_value do |network|
            puts '| ' * (level + 1)
            network.print(level + 1)
        end
    end

    def check_connection(connection)
        Log.warning "Network #{@name}:", "Wrong number of outputs (#{inputs.size}) for connection of type #{type}" if ['and', 'or', 'not'].include?(connection.type) && !(connection.outputs.size == 1)

        Log.warning "Network #{@name}:", "Wrong number of inputs (#{inputs.size}) for connection of type #{type}" if ['and', 'or'].include?(connection.type) && !(connection.inputs.size == 2)

        Log.warning "Network #{@name}:", "Wrong number of inputs (#{inputs.size}) for connection of type #{type}" if ['not'].include?(connection.type) && !(connection.inputs.size == 1)

        puts "Not all input wires could be found for connection #{name}" if connection.inputs.any? { |i| find_wire(i.name).nil? }

        return unless connection.outputs.any? { |o| find_wire(o.name).nil? }

        puts "Not all output wires could be found for connection #{name}"
    end
end
