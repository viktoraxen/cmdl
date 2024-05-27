# frozen_string_literal: true

class Blueprint
    attr_reader :name, :inputs, :outputs, :user_wires, :internal_wires, :connections, :constraints, :blueprints, :logger

    def initialize(name = '', parent_blueprint = nil, log_level = Logger::ERROR)
        @logger           = Logger.new($stdout)
        @logger.level     = parent_blueprint.nil? ? log_level : parent_blueprint.logger.level

        @basic_gates      = ['and', 'or', 'not']

        @name             = name
        @inputs           = []
        @outputs          = []
        @user_wires       = []
        @internal_wires   = []
        @connections      = {}
        @constraints      = []
        @blueprints       = {}
        @parent_blueprint = parent_blueprint
    end

    def get_blueprint(name)
        @blueprints[name]
    end

    def full_name
        return ".#{@name}" if @parent_blueprint.nil?

        parent_name = @parent_blueprint.full_name

        return ".#{@name}" if parent_name == '.'

        "#{parent_name}.#{@name}"
    end

    def find_blueprint(scope)
        # Search exhausted
        if scope == []
            puts "==========================="
            puts "Blueprint #{scope.join('.')} not found"
            puts "==========================="

            return nil 
        end

        # Potential path to blueprint
        if @blueprints.include?(scope[0])
            return @blueprints[scope[0]] if scope.length == 1

            return @blueprints[scope[0]].find_blueprint(scope[1..])
        end

        nil
    end

    def find_blueprint_absolute(scope)
        # puts "Find blueprint absolute: #{scope.join('.')} from #{@name}"
        return @parent_blueprint.find_blueprint_absolute(scope) if @parent_blueprint

        find_blueprint(scope)
    end

    def find_blueprint_relative(scope)
        # puts "Find blueprint relative: #{scope.join('.')} from #{@name}"

        # Current scope contains a potential path to the blueprint
        current_scope_result = find_blueprint(scope)
        return current_scope_result if current_scope_result

        # The blueprint is not in the current scope, so we need to go up a level
        # This will also handle the case where the current blueprint is searched for
        return @parent_blueprint.find_blueprint_relative(scope) if @parent_blueprint

        puts "Blueprint #{scope.join('.')} not found"

        nil
    end

    def add_input(input)
        if @inputs.include?(input)
            @logger.warn("Input wire #{input} already exists in blueprint #{@name}")
            return
        end

        @inputs << input
        input
    end

    def add_output(output)
        if @outputs.include?(output)
            @logger.warn("Output wire #{output} already exists in blueprint #{@name}")
            return
        end

        @outputs << output
        output
    end

    def add_wire(wire)
        if @user_wires.include?(wire)
            @logger.warn("Wire #{wire} already exists in blueprint #{@name}")
            return
        end

        @user_wires << wire
        wire
    end

    def add_internal_wire(name)
        if internal_wire_exists(name)
            @logger.warn("Internal wire #{name} already exists in blueprint #{@name}")
            return
        end

        @internal_wires << name
        name
    end

    def add_constraint(type, inputs)
        output = constraint_output(type, inputs)

        @constraints << create_constraint(type, inputs, output)

        add_internal_wire(output) unless internal_wire_exists(output)

        [output]
    end

    def add_connection(blueprint, inputs)
        if blueprint == self
            @logger.error("Blueprint #{blueprint.full_name} is the same as the current blueprint".red)

            return []
        end

        outputs = output_names(blueprint, inputs)
        name = connection_name(blueprint, inputs)

        @connections[name] = create_connection(blueprint, inputs, outputs)

        outputs.each do |output|
            add_internal_wire(output) unless internal_wire_exists(output)
        end

        outputs
    end

    def output_names(blueprint, inputs)
        blueprint.outputs.map { |output| "#{blueprint.full_name}:#{inputs.join(',')}:#{output}" }
    end

    def add_assignment(input, output)
        @constraints << create_constraint('dir', [input], output)

        [output]
    end

    def add_blueprint(blueprint)
        return if @blueprints.include?(blueprint.name)

        @blueprints[blueprint.name] = blueprint
        blueprint
    end

    def num_outputs
        @outputs.length
    end

    def internal_wire_exists(name)
        @internal_wires.include?(name)
    end

    def get_connection(name)
        @connections.find { |c| c[:name] == name }
    end

    def create_constraint(type, inputs, output)
        {
            type:   type,
            inputs: inputs,
            output: output
        }
    end

    def create_connection(blueprint, inputs, outputs)
        {
            blueprint: blueprint,
            inputs:    inputs,
            outputs:   outputs
        }
    end

    def ambiguous_name(name)
        name.include?('&') || name.include?('|') || name.include?('!')
        # return false if name[0] == '!'
    end

    def make_unambiguous(name)
        return name unless ambiguous_name(name)

        "(#{name})"
    end

    def constraint_output(type, inputs)
        ua_inputs = inputs.map { |input| make_unambiguous(input) }

        case type
        when 'and'
            "#{ua_inputs[0]}&#{ua_inputs[1]}"
        when 'or'
            "#{ua_inputs[0]}|#{ua_inputs[1]}"
        when 'not'
            "!#{ua_inputs[0]}"
        else
            raise 'Unknown constraint'
        end
    end

    def connection_name(blueprint, inputs)
        "#{blueprint.full_name}:#{inputs.join(',')}"
    end

    def indent_puts(indent, string)
        puts (' ' * indent) + string
    end

    def print(indent = 0)
        indent_puts indent, "Blueprint: #{@name}"

        indent_puts indent, "  Inputs:\n#{' ' * (indent + 4)}#{@inputs.join("\n#{' ' * (indent + 4)}")}\n\n" if @inputs.any?
        indent_puts indent, "  Outputs:\n#{' ' * (indent + 4)}#{@outputs.join("\n#{' ' * (indent + 4)}")}\n\n" if @outputs.any?
        indent_puts indent, "  User Wires:\n#{' ' * (indent + 4)}#{@user_wires.join("\n#{' ' * (indent + 4)}")}\n\n" if @user_wires.any?
        indent_puts indent, "  Internal Wires:\n#{' ' * (indent + 4)}#{@internal_wires.join("\n#{' ' * (indent + 4)}")}\n\n" if @internal_wires.any?

        if @constraints.any?
            indent_puts indent, '  Constraints:'

            @constraints.each do |connection|
                indent_puts indent, "    Type:    #{connection[:type]}"
                indent_puts indent, "    Inputs:  #{connection[:inputs].join(', ')}"
                indent_puts indent, "    Outputs: #{connection[:output]}"
                indent_puts indent, ''
            end
        end

        if @connections.any?
            indent_puts indent, '  Connections:'

            @connections.each do |name, connection|
                indent_puts indent, "    Name:      #{name}"
                indent_puts indent, "    Blueprint: #{connection[:blueprint]}"
                indent_puts indent, "    Inputs:    #{connection[:inputs].join(', ')}"
                indent_puts indent, "    Outputs:   #{connection[:outputs].join(', ')}"
                indent_puts indent, ''
            end
        end

        return unless @blueprints.any?

        indent_puts indent, 'Blueprints:'

        @blueprints.each_value do |blueprint|
            blueprint.print(indent + 2)
        end
    end

    def to_s 
        "<Blueprint>: #{full_name}"
    end

    def inspect
        to_s
    end
end
