#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'core/log/log'
require_relative 'core/cmdl_run'

require_relative 'core/utils/print'
require_relative 'core/cli/cli'

cmdl_sim = CliApp.new('CMDL Simulator Interface', '0.1.0',
                      "Simulator interface for CMDL. \nGenerates a dataflow network using a description of a logical \nnetwork and allows the user to interact with the network by\nchanging the values of the defined wires.")

cmdl_sim.add_flag('s', 'syntax-tree-print',  'Print the syntax tree')
cmdl_sim.add_flag('t', 'template-print',     'Print the template')
cmdl_sim.add_flag('n', 'network-print',      'Print the network')
cmdl_sim.add_flag('f', 'full-network-print', 'Print all information about each network')
cmdl_sim.add_flag('d', 'deep-network-print', 'Print the network with all components expanded')
cmdl_sim.add_flag('r', 'result-print',       'Print the final state of the network')
cmdl_sim.add_flag('l', 'logging',            'Print the full log')
cmdl_sim.add_flag('m', 'simulation',         'Open simulation interface')
cmdl_sim.add_flag('c', 'clear',              'Clear terminal after each print')

cmdl_sim.add_parameter('p', 'print-depth', Integer, 'Recursive depth limit for component printing')

cmdl_sim.add_argument('circuit', 'The file contatning the CMDL circuit to synthesize.')
cmdl_sim.add_argument('simulation', 'The file containing the simulation to be ran.')

cmdl_sim.parse(ARGV) do |opts|
    run opts
end
