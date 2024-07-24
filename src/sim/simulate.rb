# frozen_string_literal: true

require_relative '../core/utils/print'

require_relative '../sim/interface/interface'

def each_command(input, &block)
    input.each_line.reject { |l| l =~ /^\s"$/ }.map(&:strip).each(&block)
end

def print_state(interface, opts)
    full_nw_print = opts[:full_network_print]
    deep_nw_print = opts[:deep_network_print]
    nw_print_depth = opts[:print_depth] || 999
    clear = opts[:clear]

    system 'clear' if clear
    interface.print(full_nw_print, deep_nw_print, nw_print_depth)
end

def simulation_file(interface, opts)
    input = File.read(opts[:simulation])

    if input.nil?
        puts "Could not find simulation file #{opts[:simulation]}"
        return
    end

    each_command(input) do |line|
        print_state(interface, opts)
        input = line
        print "Next action: #{input}"

        $stdin.gets.chomp

        id, value = input.split('<=').map(&:strip)
        interface.change(id, value.to_i)
    end
end

def simulation_cli(interface, opts)
    loop do
        print_state(interface, opts)
        input = get_input

        break if input == 'q'

        unless valid_input(input)
            puts 'Enter an assignment on the form: <id> <= <value>'
            next
        end

        id, value = input.split('<=').map(&:strip)
        interface.change(id, value.to_i)
    end
end

def simulation_interface(network, opts = {})
    interface = Interface.new(network)

    if opts[:simulation].nil?
        simulation_cli(interface, opts)
    else
        simulation_file(interface, opts)
    end

    print 'Simulation finished.'
end

def get_input
    print '> '
    $stdin.gets.strip
end

def valid_input(str)
    str.match?(/^[a-zA-Z0-9]+\s*<=\s*\d+$/)
end
