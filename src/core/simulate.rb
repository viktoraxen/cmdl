# frozen_string_literal: true

require_relative '../core/utils/print'

require_relative '../sim/interface/interface'

def simulation_interface(network, opts = {})
    interface = Interface.new(network)

    full_nw_print = opts[:full_network_print]
    deep_nw_print = opts[:deep_network_print]
    clear = opts[:clear]

    loop do
        system 'clear' if clear
        network.print(full_nw_print, deep_nw_print)

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

def get_input
    print '> '
    $stdin.gets.chomp
end

def valid_input(str)
    str.match?(/^[a-zA-Z0-9]+\s*<=\s*\d+$/)
end
