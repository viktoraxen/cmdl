#!/home/viktor/.rvm/rubies/ruby-3.3.0/bin/ruby

# frozen_string_literal: true

require_relative 'cmdlparser'
require_relative 'network'
require_relative 'log'

Log.initialize(Logger::INFO)

def cmdl_file(filename, print_all)
    parser = CmdlParser.new(Logger::ERROR)

    string = File.read(filename)
    tree = parser.parse(string)
    # tree.print
    # root = tree.evaluate(Scope.new('root'))

    # network = Network.create_network(root)
    # network.print(print_all: print_all)
end

if ARGV.empty?
    puts 'CMDL - Component Description Language v0.1.0'
    puts ''
    puts '  Usage: cmdl [options] [arguments]'
    puts ''
    puts '  Options:'
    puts '    -p, --print-all  Print all components'
    puts ''
    puts '  Arguments:'
    puts '    <filename>       CMDL file to parse'
else
    print_all = ARGV.map { |arg| ['-p', '--print-all'].include? arg }.any?
    cmdl_file(ARGV.reject{ |arg| ['-p', '--print-all'].include? arg }[0], print_all)
end
