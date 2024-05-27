# frozen_string_literal: true

require 'colorize'

require_relative 'log'

class Wire
    attr_reader :name, :cleared
    attr_accessor :constraint, :connections, :declared

    def initialize(name)
        @name        = name
        @constraint  = nil
        @connections = []
    end

    def add_connection(connection)
        return if @connections.include? connection
        Log.debug "Wire #{@name}: Adding connection #{connection.name} to connections #{connections.map(&:name)}"

        @connections << connection
        connection.add_input(self)
    end

    def remove_connection(connection)
        return unless @connections.include? connection
        Log.debug "Wire #{@name}: Removing connection #{connection.name} from connections #{connections.map(&:name)}"

        @connections.delete(connection)

        if @connections.empty?
            @constraint.remove_output(self) unless @constraint.nil?
        end

        connection.remove_input(self)
    end

    def set_constraint(connection)
        return if @constraint == connection
        Log.debug "Wire #{@name}: Setting constraint #{connection.name}"

        @constraint.remove_output(self) unless @constraint.nil?

        @constraint = connection
        connection.add_output(self)
    end

    def remove_constraint(connection)
        return unless @constraint == connection
        Log.debug "Wire #{name}: Remove constraint #{connection.name}"

        @constraint = nil
        connection.remove_output(self)
    end

    def useless?
        if @connections.empty? && @constraint.nil?
            Log.debug "Wire #{@name}: Useless"
            return true
        end

        Log.debug "Wire #{@name}: Not useles"
        false
    end
end

class Connection
    @@colors = [
        :light_green,
        :light_yellow,
        :light_blue,
        :light_magenta,
        :light_cyan]

    attr_reader :cleared
    attr_accessor :type, :inputs, :outputs

    def initialize(type, inputs, outputs = [])
        @type    = type
        @inputs  = inputs
        @outputs = outputs

        @inputs.each { |input| input.connections << self }
        @outputs.each { |output| output.set_constraint(self) }
    end

    def add_input(wire)
        return if @inputs.include? wire
        Log.debug "Connection #{name}: Adding input #{wire.name} to inputs #{inputs.map(&:name)}"

        @inputs << wire
        wire.add_connection(self)
    end

    def remove_input(wire)
        return unless @inputs.include? wire
        Log.debug "Connection #{name}: Removing input #{wire.name} from inputs #{inputs.map(&:name)}"

        @inputs.delete(wire)

        if @inputs.empty?
            while !@outputs.empty?
                output = @outputs.pop
                output.remove_connection(self)
            end
        end

        wire.remove_connection(self)
    end

    def add_output(wire)
        return if @outputs.include? wire
        Log.debug "Connection #{name}: Adding output #{wire.name} to outputs #{outputs.map(&:name)}"

        @outputs << wire
        wire.set_constraint(self)
    end

    def remove_output(wire)
        return unless @outputs.include? wire
        Log.debug "Connection #{name}: Removing output #{wire.name} from outputs #{outputs.map(&:name)}"

        @outputs.delete(wire)
    
        if @outputs.empty?
            while !@inputs.empty?
                input = @inputs.pop
                input.remove_connection(self)
            end
        end

        wire.remove_constraint(self)
    end

    def useless?
        if @inputs.empty? && @outputs.empty?
            Log.debug "Connection #{name}: Useles"
            return true
        end

        Log.debug "Connection #{name}: Not useless"
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
end

class Blueprint
    attr_reader :connections, :wires

    def initialize
        @connections = {}
        @wires       = {}
    end

    def add_connection(type, inputs, outputs = [])
        @connections[type] ||= []

        Log.debug "Blueprint.add_connection: Adding connection #{type}, inputs: #{inputs.map(&:name)}"

        # Check if connection already exists
        @connections[type].each do |connection|
            if connection.inputs == inputs
                Log.debug "Blueprint.add_connection: Connection already exists."
                return connection 
            end
        end

        outputs.each do |output|
            add_wire(output) if find_wire(output.name).nil?
        end

        inputs.each do |input|
            add_wire(input) if find_wire(input.name).nil?
        end

        # Create internal gate output wires
        if is_gate(type)
            output_wire = Wire.new(gate_output_name(type, inputs))
            outputs << add_internal_wire(output_wire)
        end

        # Create a new connection
        @connections[type] << Connection.new(type, inputs, outputs)

        @connections[type].last
    end

    def get_connection_outputs(connection, num = 1)
        # Create new wires if necessary
        (connection.outputs.size..num - 1).each do |i|
            output_wire_name = connection_output_name(connection, i)
            output_wire = Wire.new(output_wire_name, true)
            add_internal_wire(output_wire)
            connection.add_output(output_wire)
        end

        # Return the requested number of outputs
        connection.outputs[0..num]
    end

    def add_wire(wire, type = 'user')
        @wires[type] ||= []

        existing_wire = @wires[type].find { |w| w == wire }

        if existing_wire
            Log.debug "Blueprint.add_wire: Wire #{wire.name} already exists".red
            declare_wire(existing_wire)
            return existing_wire 
        end

        Log.debug "Blueprint.add_wire: Adding #{type} wire #{wire.name}"

        @wires[type] << wire
        wire
    end

    def add_internal_wire(name)
        # declare_wire(name)
        add_wire(name, 'internal')
    end

    def add_input_wire(name)
        declare_wire(name)
        add_wire(name, 'input')
    end

    def add_output_wire(name)
        declare_wire(name)
        add_wire(name, 'output')
    end

    def declare_wire(wire)
        return if wire_declared?(wire)
        Log.debug "Blueprint.declare_wires: Declaring wire #{wire.name}"

        @wires['declared'] ||= []
        @wires['declared'] << wire
        wire
    end

    def wire_declared?(wire)
        return false unless @wires['declared']

        @wires['declared'].include? wire
    end

    def find_wire(name)
        @wires.each do |type, wires|
            # Log.debug "Blueprint.find_wire: Looking for #{name} in #{type} wires"
            found_wire = wires.find { |w| w.name == name }
            return found_wire if found_wire
        end
        nil
    end

    def undeclared_wires
        Log.debug 'Blueprint.undeclared_wires: Finding undeclared wires'
        undeclared_wires = []

        @wires.each do |type, wires|
            next if type == 'declared' or type == 'internal'

            wires.each do |wire|
                next if wire_declared? wire
                Log.debug "Blueprint.undeclared_wires: Found undeclared wire #{wire.name}"
                undeclared_wires << wire
            end
        end

        undeclared_wires
    end

    def cleanup
        Log.debug 'Blueprint.cleanup: Cleaning up blueprint'

        clean_wires
        clean_connections
    end

    def clean_wires
        @wires.each do |type, wires|
            @wires[type] = wires.select do |wire| 
                not wire.useless?
            end
        end
    end

    def clean_connections
        @connections.each do |type, connections|
            @connections[type] = connections.select do |connection| 
                not connection.useless?
            end
        end
    end

    def connection_output_name(connection, index = 0)
        "#{connection.name}:#{index}"
    end

    def is_gate(type)
        %w[not and or].include? type
    end

    def gate_output_name(type, inputs)
        input_names = inputs.map(&:name)

        case type
        when 'not'
            return "!#{input_names[0]}"
        when 'and'
            return input_names.join('&')
        when 'or'
            return input_names.join('|')
        end

        Log.error "Unknown gate type #{type}"
        raise ArgumentError, "Unknown gate type #{type}"
    end

    def print(level = 0)
        text = 'Connections'.light_blue
        puts ('| ' * (level + 1)) + text unless @connections.empty?

        @connections.each do |type, connections|
            connections.each do |connection|
                name = connection.name_colorized
                outputs = connection.outputs_colorized

                indent = '| ' * (level + 2)
                puts "#{indent}#{name} -> #{outputs}"
            end
        end

        @wires.each do |type, wires|
            next if wires.empty? or type == 'declared'

            indent = '| ' * (level + 1)
            text = "#{type.capitalize} wires".light_blue

            puts "#{indent}#{text}"

            wires.each do |wire|
                color = wire_declared?(wire) ? :light_green : :light_red
                wire_name = wire.name.colorize(color)
                wire_name.colorize(:background => :red) unless wire_declared? wire
                puts "#{indent}| #{wire_name}"
            end
        end
    end
end
