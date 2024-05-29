#!/home/viktor/.rvm/rubies/ruby-3.3.0/bin/ruby

# frozen_string_literal: true

require 'sod'
require_relative 'cmdlparser'
require_relative 'network'
require_relative 'log'

Log.initialize(Logger::INFO)

inputs = {:print_all => false}

def exit(string)
    string == 'exit' || string == 'quit' || string == 'q'
end

def prompt(text)
    print text
    gets.chomp
end

def cmdl_file(filename, print_all)
    parser = CmdlParser.new(Logger::ERROR)

    string = File.read(filename)
    tree = parser.parse(string)
    root = tree.evaluate(Scope.new('root'))

    network = Network.create_network(root)
    network.print(print_all: print_all)
end

def cmdl_prompt
    parser = CmdlParser.new(Logger::ERROR)

    string = prompt '> '

    until exit(string)
        parser.parse(string).evaluate(bp_global).print

        string = prompt '> '
    end
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

# class PrintAll < Sod::Action
#     description 'Print all components'

#     on %w[-p --print-all]

#     def call(*)
#         context.input[:print_all] = true
#     end
# end

# class FileAction < Sod::
#     description 'Parse a CMDL file'

#     on %w[-f --file], argument: 'FILENAME'
#     # on PrintAll

#     def call(filename, *)
#         cmdl_file(filename)
#     end
# end

# cmdl_context = Sod::Context[input: {}]

# cli = Sod.new :cmdl, banner: 'CMDL - Component Description Languague v0.1.0' do
#     on FileAction

#     on Sod::Prefabs::Actions::Help, self
#     on Sod::Prefabs::Actions::Version, "CMDL v0.1.0"
# end

# cli.call
