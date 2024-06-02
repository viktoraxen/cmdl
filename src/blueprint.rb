# frozen_string_literal: true

require 'colorize'

require_relative 'log/log'

class Blueprint
    class Wire
        attr_reader :name, :constraint, :connections, :declared
        attr_accessor :type

        def initialize(name, type = 'user')
            @name        = name
            @constraint  = nil
            @connections = []
            @type        = type
            @declared    = false
        end

        def assigned?
            !@constraint.nil?
        end

        def declare
            Log.debug "Wire #{name}:", 'Declaring'
            @declared = true
        end

        def undeclare
            Log.debug "Wire #{name}:", 'Undeclaring'
            @declared = false
        end

        def add_connection(connection)
            return if @connections.include? connection

            Log.debug "Wire #{@name}:", "Adding connection #{connection.name}", "to connections #{connections.map(&:name)}"

            @connections << connection
            connection.add_input(self)
        end

        def remove_connection(connection)
            return unless @connections.include? connection

            Log.debug "Wire #{@name}:", "Removing connection #{connection.name}", "from connections #{connections.map(&:name)}"

            @connections.delete(connection)

            if @connections.empty?
                Log.debug "Wire #{@name}:", "Removing constraint #{@constraint}"
                @constraint&.remove_output(self)
                @constraint = nil
            end

            connection.remove_input(self)
        end

        def set_constraint(connection)
            return if @constraint == connection

            Log.debug "Wire #{@name}:", " Setting constraint #{connection.name}"

            unless @constraint.nil?
                Log.debug "Wire #{@name}:", "Removing old constraint #{@constraint}"
                @constraint.remove_output(self)
            end

            @constraint = connection
            connection.add_output(self)
        end

        def remove_constraint(connection)
            return unless @constraint == connection

            Log.debug "Wire #{name}:", "Remove constraint #{connection.name}"

            @constraint = nil
            connection.remove_output(self)
        end

        def useless?
            if @connections.empty? && @constraint.nil?
                # Log.debug "Wire #{@name}:", 'Useless'
                return true
            end

            # Log.debug "Wire #{@name}:", 'Not useles'
            false
        end

        def inspect
            to_s
        end

        def to_s
            "Wire #{@name}"
        end
    end

    class Connection
        @@colors = %i[light_green
                      light_yellow
                      light_blue
                      light_magenta
                      light_cyan]

        attr_reader :type, :inputs, :outputs

        def initialize(type, inputs, outputs = [])
            @type    = type
            @inputs  = []
            @outputs = []

            inputs.each { |input| add_input(input, true) }
            outputs.each { |output| add_output(output, true) }
        end

        def add_input(wire, force = false)
            return if @inputs.include?(wire) and not force

            Log.debug "Connection #{name_colorized}:", "Adding input #{wire.name} to inputs #{inputs.map(&:name)}"

            @inputs << wire
            wire.add_connection(self)
        end

        def remove_input(wire)
            return unless @inputs.include? wire

            Log.debug "Connection #{name_colorized}:", "Removing input #{wire.name} from inputs #{inputs.map(&:name)}"

            @inputs.delete(wire)

            if @inputs.empty?

                Log.debug "Connection #{name_colorized}:", 'Removing all outputs'

                until @outputs.empty?
                    Log.debug "Connection #{name_colorized}:", "Removing output #{output.name}"
                    output = @outputs.pop
                    output.remove_constraint(self)
                end
            end

            wire.remove_connection(self)
        end

        def add_output(wire, force = false)
            return if @outputs.include?(wire) and not force

            Log.debug "Connection #{name_colorized}:", "Adding output #{wire.name} to outputs #{outputs.map(&:name)}"

            @outputs << wire

            wire.set_constraint(self)
        end

        def remove_output(wire)
            if @outputs.include? wire
                Log.debug "Connection #{name_colorized}:", "Removing output #{wire.name} from outputs #{outputs.map(&:name)}"

                @outputs.delete(wire)

                if @outputs.empty?

                    Log.debug "Connection #{name_colorized}:", 'Removing all inputs'

                    until @inputs.empty?
                        input = @inputs.pop
                        Log.debug "Connection #{name_colorized}:", "Removing input #{input.name}"
                        input.remove_connection(self)
                    end
                end
            end

            wire.remove_constraint(self)
        end

        def useless?
            if @inputs.empty? && @outputs.empty?
                Log.debug "Connection #{name_colorized}:", 'Useles'
                return true
            end

            Log.debug "Connection #{name_colorized}:", 'Not useless'
            false
        end

        def name
            "#{@type}(#{@inputs.map(&:name).join(',')})"
        end

        def name_colorized
            inputs = @inputs.map(&:name).map.with_index do |name, i|
                name.colorize(@@colors[i % @@colors.size])
            end

            "#{@type}(#{inputs.join(',')})"
        end

        def outputs_colorized
            outputs = @outputs.map(&:name).map.with_index do |name, i|
                name.colorize(@@colors[(@@colors.size - 1 - i) % @@colors.size])
            end

            outputs.join(', ')
        end

        def inspect
            to_s
        end

        def to_s
            "Connection #{name}"
        end
    end

    attr_reader :connections, :wires

    def initialize(scope)
        @connections = {}
        @wires       = {}
        @scope       = scope

        create_internal_wire('VCC')
        create_internal_wire('GND')
    end

    #
    # Connections: Actions
    #

    def create_connection(type, inputs, num_outputs = 1)
        @connections[type] ||= []

        # Check if connection already exists
        connection = find_connection(type, inputs)

        unless connection
            Log.debug "Blueprint #{full_name}:", "Creating connection:\n" \
                                                 "#{"\t" * 5}type:    #{type}\n" \
                                                 "#{"\t" * 5}inputs:  #{inputs.map(&:name)}\n" \
                                                 "#{"\t" * 5}outputs: #{num_outputs}\n"

            connection = Connection.new(type, inputs)

            @connections[type] << connection
        end

        if connection.outputs.size < num_outputs
            # Create output wires
            (0..num_outputs - 1).each do |i|
                output_wire_name = connection_output_name(connection, i)
                output_wire = create_internal_wire(output_wire_name)
                connection.add_output(output_wire)
            end
        end

        connection
    end

    #
    # Connections: Finders
    #

    def find_connection(type, inputs)
        @connections[type].each do |connection|
            return connection if connection.inputs == inputs
        end

        nil
    end
    
    #
    # Connections: Helpers
    #

    def connection_output_name(connection, i = 0)
        if ['not', 'and', 'or'].include? connection.type
            raise "Invalid index for gate connection: #{i}" if i.positive?

            return gate_output_name(connection)
        end

        "#{connection.name}:#{i}"
    end

    def gate_output_name(connection)
        input_names = connection.inputs.map(&:name)

        case connection.type
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
            name = input_names.join('|')
            return name
        end

        raise ArgumentError, "Unknown gate type #{type}"
    end

    #
    # Wires: Actions
    #

    def create_wire(name, size, type = :user)
        @wires[type] ||= {}

        return find_wire(name) if wire_exists?(name)

        Log.debug "Blueprint #{full_name}:", "Creating #{type} wire #{name}[#{size}]"

        if size.nil?
            @wires[type][name] = {
                wires:    [Wire.new(name, type)],
                declared: false
            }

            return name
        end

        @wires[type][name] = {
            wires:    [],
            declared: false
        }

        (0..size - 1).each do |i|
            @wires[type][name][:wires] << Wire.new("#{name}[#{i}]", type)
        end

        name
    end

    def create_internal_wire(name)
        create_wire(name, nil, :internal)
    end

    def create_input_wire(name, size)
        create_wire(name, size, :input)
    end

    def create_output_wire(name, size)
        create_wire(name, size, :output)
    end

    def declare_wire(name)
        return if !wire_exists? name or wire_declared? name

        Log.debug "Blueprint #{full_name}:", "Declaring wire #{name}"

        find_wire(name)[:declared] = true
    end

    def assign_wires(inputs, outputs)
        Log.debug "Blueprint #{full_name}:", 'Assigning wires', "Inputs: #{inputs.map(&:name)}", "Outputs: #{outputs.map(&:name)}"
        connection = create_connection('direct', inputs, 0)

        outputs.each do |output|
            connection.add_output(output, true)
        end

        outputs
    end

    #
    # Wires: Queries
    #

    def wire_exists?(name)
        @wires.each_value do |wires|
            return true if wires.key? name
        end

        false
    end

    def wire_declared?(name)
        wire = find_wire(name)
        return false if wire.nil?

        wire[:declared]
    end

    def wire_is_input?(wire)
        @wires['input']&.include? wire
    end

    def wire_useless?(name)
        return true unless wire_exists? name

        wire = find_wire(name)

        wire[:wires].map(&:useless?).any?
    end

    #
    # Wires: Finders
    #

    def find_wire(name, index = nil)
        @wires.each_value do |wires|
            return wires[name] if wires.key? name
        end

        nil
    end

    def undeclared_wires
        Log.debug "Blueprint #{full_name}:", 'Finding undeclared wires'
        undeclared_wires = []

        @wires.each do |type, wires|
            next if type == :internal

            wires.each_key do |name|
                next if wire_declared? name

                Log.debug "Blueprint #{full_name}:", "Found undeclared wire #{name}"

                undeclared_wires << name
            end
        end

        undeclared_wires
    end

    #
    # Cleanup
    #

    def cleanup
        Log.debug "Blueprint #{full_name}:", 'Cleaning up blueprint'

        # clean_wires
        clean_connections
    end

    def clean_wires
        @wires.each do |type, wires|
            next unless %i[user internal].include? type

            @wires[type] = wires.reject { |w| wire_useless? w }
        end
    end

    def clean_connections
        @connections.each do |type, connections|
            @connections[type] = connections.reject(&:useless?)
        end
    end

    #
    # Print
    #

    def print(level = 0)
        text = 'Connections'.light_blue
        puts ('| ' * (level + 1)) + text unless @connections.empty?

        @connections.each_value do |connections|
            connections.each do |connection|
                name = connection.name_colorized
                outputs = connection.outputs_colorized

                indent = '| ' * (level + 2)
                puts "#{indent}#{name} -> #{outputs}"
            end
        end

        @wires.each do |type, wires|
            next if wires.empty?

            indent = '| ' * (level + 1)
            text = "#{type.capitalize} wires".light_blue

            puts "#{indent}#{text}"

            wires.each do |name, wire|
                string = "#{name}, #{wire[:wires].size}"
                string = string.colorize(:light_red) if wire_useless? name
                puts "#{indent}| #{string}"
            end
        end
    end

    def full_name
        @scope.full_name
    end

    def inspect
        to_s
    end

    def to_s
        "Blueprint  #{full_name}}"
    end
end
