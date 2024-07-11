#!/home/viktor/.rvm/rubies/ruby-3.3.0/bin/ruby

# frozen_string_literal: true

require_relative 'log/log'
require_relative 'core/run_language'

$flags = {
    '--syntax-tree-print'  => 'Print the syntax tree',
    '--template-print'     => 'Print the template',
    '--network-print'      => 'Print the network',
    '--full-network-print' => 'Print all information about each network',
    '--deep-network-print' => 'Print the network with all components expanded',
    '--logging'            => 'Print the full log'
}

def flag_shorthand(flag)
    "-#{flag.scan(/--([a-z\-?]+)/).flatten.first[0]}"
end

def flag_symbol(flag)
    flag.gsub(/^-+/, '').gsub('-', '_').to_sym
end

def get_flag(flag)
    ARGV.map { |arg| [flag, flag_shorthand(flag)].include? arg }.any?
end

def get_flags
    $flags.keys.to_h do |flag|
        [flag_symbol(flag), get_flag(flag)]
    end
end

def get_filename
    return ARGV.first
end

if ARGV.empty?
    puts 'CMDL - Component Description Language v0.1.0'
    puts ''
    puts '  Usage: cmdl [filename] [options]'
    puts ''
    puts '  Options:'

    flag_width = $flags.keys.map do |flag, _|
        [flag, flag_shorthand(flag)].join(', ').length
    end.max

    $flags.each do |flag, description|
        flag_string = [flag_shorthand(flag), flag].join(', ')
        puts "    #{flag_string.ljust(flag_width )}  #{description}"
    end
else
    cmdl_file(get_filename, get_flags)
end
