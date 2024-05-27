# frozen_string_literal: true

require 'logger'
require 'colorize'

require_relative 'constraint'

class Network
    attr_reader :input_wires, :output_wires

    def initialize(blueprint, scope_suffix = '', local_suffix = '', log_level = Logger::ERROR)
        @logger         = Logger.new($stdout)
        @logger.level   = log_level

        @blueprint      = blueprint
        @scope_suffix   = scope_suffix
        @local_suffix   = local_suffix

        @input_wires    = {}
        @output_wires   = {}

        @constraints    = {}
        @user_wires     = {}
        @internal_wires = {}

        add_internal_wire(ground_name)
        add_internal_wire(vcc_name)

        get_wire(ground_name).value = false
        get_wire(vcc_name).value    = true

        @components     = {}
    end

    def scope
        scope = @blueprint.full_name
        scope = "#{scope}#{@scope_suffix}" unless @scope_suffix == ''
        scope
    end

    def create
        @logger.debug("\nCreating network from blueprint #{@blueprint.name}")

        @blueprint.inputs.each do |input|
            add_input(input)
        end

        @blueprint.outputs.each do |output|
            add_output(output)
        end

        @blueprint.user_wires.each do |wire|
            add_user_wire(wire)
        end

        @blueprint.internal_wires.each do |wire|
            add_internal_wire(wire)
        end

        @blueprint.constraints.each do |constraint|
            add_constraint(constraint)
        end

        @blueprint.connections.each do |name, connection|
            add_connection(name, connection)
        end

        create_interface
    end

    def create_interface
        { inputs: @input_wires, outputs: @output_wires }
    end

    def add_input(name)
        global_name = wire_name(name)

        @logger.debug("Adding input #{name}: #{global_name}")

        @input_wires[name] = Wire.new(global_name)
    end

    def add_output(name)
        global_name = wire_name(name)

        @logger.debug("Adding output #{name}: #{global_name}")

        @output_wires[name] = Wire.new(global_name)
    end

    def add_user_wire(name)
        global_name = wire_name(name)
    
        @logger.debug("Adding user wire #{name}: #{global_name}")

        @user_wires[name] = Wire.new(global_name)
    end

    def add_internal_wire(name)
        global_name = wire_name(name)

        @logger.debug("Adding internal wire #{name}: #{global_name}")

        @internal_wires[name] = Wire.new(global_name)
    end

    def add_constraint(constraint)
        type = constraint[:type]

        input_names = constraint[:inputs].map do |input|
            wire_name(input)
        end

        input_wires = constraint[:inputs].map do |input_name|
            get_wire(input_name)
        end

        output_name = wire_name(constraint[:output])

        output_wire = get_wire(constraint[:output])

        # name = constraint_name(type, constraint[:inputs], constraint[:output])
        global_name = constraint_name(type, input_names, output_name)

        case type
        when 'and'
            constraint_object = AndGate.new(global_name, input_wires, output_wire)
        when 'or'
            constraint_object = OrGate.new(global_name, input_wires, output_wire)
        when 'not'
            constraint_object = NotGate.new(global_name, input_wires, output_wire)
        when 'dir'
            constraint_object = DirectGate.new(global_name, input_wires, output_wire)
        else
            @logger.error("Unknown constraint type #{type}".red)
            return
        end

        name = "#{type}(#{constraint[:inputs].join(',')})->#{constraint[:output]}"

        @logger.debug("Adding constraint #{name}: #{global_name}")

        @constraints[name] = constraint_object
    end

    def add_connection(_, connection)
        @logger.debug('')

        input_names = connection[:inputs].map do |input|
            wire_name(input)
        end

        output_names = connection[:outputs].map do |output|
            wire_name(output)
        end

        global_suffix = "(#{input_names.join(',')})"
        local_suffix = "(#{connection[:inputs].join(',')})"

        network = Network.new(connection[:blueprint], global_suffix, local_suffix, @logger.level)
        network.create

        input_wires = connection[:inputs].map do |input_name|
            get_wire(input_name)
        end

        output_wires = connection[:outputs].map do |output_name|
            get_wire(output_name)
        end

        network.input_wires.each_with_index do |(name, wire), index|
            @logger.debug("Adding constraint dir #{connection[:inputs][index]} -> #{name}")

            constraint_name = constraint_name('dir', [input_names[index]], wire.name)
            local_name = "dir(#{input_names[index]})->#{name}"

            @constraints[local_name] = DirectGate.new(constraint_name, [input_wires[index]], wire)
        end

        network.output_wires.each_with_index do |(name, wire), index|
            @logger.debug("Adding constraint dir #{name} -> #{connection[:outputs][index]}")

            constraint_name = constraint_name('dir', [wire.name], output_names[index])
            local_name = "dir(#{name})->#{connection[:outputs][index]}"

            @constraints[local_name] = DirectGate.new(constraint_name, [wire], output_wires[index])
        end

        @components[network.scope] = network
    end

    def ground_name
        '0'
    end

    def vcc_name
        '1'
    end

    def get_wire(name)
        return @input_wires[name]    if @input_wires.include?(name)
        return @output_wires[name]   if @output_wires.include?(name)
        return @user_wires[name]     if @user_wires.include?(name)
        return @internal_wires[name] if @internal_wires.include?(name)

        @logger.error("Wire #{name} not found".red)
        Wire.new('NIL')
    end

    def scope_name(blueprint)
        name = blueprint.full_name

        name += "(#{blueprint.inputs.join(',')})" if blueprint.inputs.any?

        name
    end

    def wire_name(name)
        "#{scope}:#{name}"
    end

    def constraint_name(type, inputs, output)
        "#{scope}:#{type}(#{inputs.join(',')})->#{output}"
    end

    def print(level = 0)
        puts "#{'|   ' * level}#{@blueprint.name == '' ? 'Network' : "Component #{@blueprint.full_name}"}#{@local_suffix}"

        print_wires_pretty(@input_wires, level) unless @input_wires.empty?
        print_wires_pretty(@output_wires, level) unless @output_wires.empty?
        print_wires_pretty(@user_wires, level) unless @user_wires.empty?

        unless @components.empty?
            @components.values.each do |component|
                puts '|   ' * (level + 1)
                component.print(level + 1)
            end
        end
    end

    def debug_print
        puts "Network for blueprint #{@name}"

        unless @input_wires.empty?
            puts 'Input wires:'
            print_wires(@input_wires, true)

            puts ''
        end

        unless @output_wires.empty?
            puts 'Output wires:'
            print_wires(@output_wires, true)

            puts ''
        end

        unless @user_wires.empty?
            puts 'User wires:'
            print_wires(@user_wires, true)

            puts ''
        end

        unless @internal_wires.empty?
            puts 'Internal wires:'
            print_wires(@internal_wires, true)

            puts ''
        end

        unless @constraints.empty?
            puts 'Constraints:'
            print_constraints(@constraints)
        end

        unless @components.empty?
            puts 'Components:'
            @components.each_value do |component|
                puts ''
                component.debug_print
            end
            puts ''
        end
    end

    def colorize_value(value)
        case value
        when '<nil>'
            value.red
        when 'false'
            value.light_red
        when 'true'
            value.green
        else
            value
        end
    end

    def print_wires_pretty(wires, level = 0)
        # puts "printing pretty wires"

        names = wires.keys
        values = wires.map { |_, wire| wire.value.to_s }

        values = values.map { |value| colorize_value(value) }

        names_width = names.map(&:length).max
        values_width = values.map(&:length).max

        names.each_with_index do |name, i|
            puts "#{'|   ' * (level + 1)}#{name.ljust(names_width)} #{values[i].ljust(values_width)}"
        end
    end

    def print_wires(wires, debug = false)
        names = wires.keys
        values = wires.map { |_, wire| wire.value.to_s }

        constraints = wires.values.map(&:constraint).map { |c| c.nil? ? '' : c.expression }

        names_width = (names.map(&:length) << 4).max
        values_width = (values.map(&:length) << 6).max
        constraints_width = (constraints.map(&:length) << 10).max

        title_name_string       = 'NAME'.ljust(names_width)
        title_value_string      = 'VALUE'.ljust(values_width)
        title_constraint_string = 'CONSTRAINT'.ljust(constraints_width)

        title_string = "#{title_name_string} | #{title_value_string}"
        title_string += " | #{title_constraint_string}" if debug

        divider_size = names_width + values_width + 3
        divider_size += constraints_width + 3 if debug
        divider = ''.ljust(divider_size, '-')

        puts title_string
        puts divider

        names.each_with_index do |name, i|
            name_string = name.ljust(names_width)

            value_string = values[i].ljust(values_width)
            case values[i]
            when '<nil>'
                value_string = value_string.red
                # value_string = "\e[#{31}m#{value_string}\e[0m"
            when 'false'
                value_string = value_string.light_red
            when 'true'
                value_string = value_string.green
            end

            constraint_string = constraints[i].ljust(constraints_width)

            string = "#{name_string} | #{value_string}"
            puts debug ? "#{string} | #{constraint_string}" : string
        end
    end

    def print_constraints(constraints)
        # type_width = (constraints.keys.map(&:length) << 4).max
        type_width   = (constraints.values.map { |c| c.type_s.length } << 6).max
        inputs_width = (constraints.values.map { |c| c.inputs.map(&:name).join(', ').length } << 6).max
        output_width = (constraints.values.map { |c| c.output.name.length } << 6).max

        puts "#{'NAME'.ljust(type_width)} | #{'INPUTS'.ljust(inputs_width)} -> #{'OUTPUT'.ljust(output_width)}"
        puts "#{''.ljust(type_width, '-')}---#{''.ljust(inputs_width, '-')}----#{''.ljust(output_width, '-')}"

        constraints.each do |name, constraint|
            puts "#{constraint.type_s.ljust(type_width)} | #{constraint.inputs.map(&:name).join(', ').ljust(inputs_width)} -> #{constraint.output.name.ljust(output_width)}"
        end
    end
end
