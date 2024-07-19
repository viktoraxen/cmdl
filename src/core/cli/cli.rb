# frozen_string_literal: true

require_relative 'flag'
require_relative 'arg'

class CliApp
    def initialize(title, version, description = '')
        @title       = title
        @version     = version
        @description = description
        @arguments   = []
        @flags       = []
    end

    def parse(argv)
        return help if argv.empty?

        args = @flags.to_h { |flag| [flag.symbol, false] }
        args = args.merge(@arguments.to_h { |arg| [arg.symbol, nil] })

        argv.each do |arg|
            unless arg.start_with?('-')
                args[@arguments.shift.symbol] = arg
                next
            end

            @flags.each do |flag|
                args[flag.symbol] = true if flag.match(arg)
            end
        end

        yield args
    end

    def add_argument(name, description)
        @arguments << CliArgument.new(name, description)
    end

    def add_flag(short, long, description)
        @flags << CliFlag.new(short, long, description)
    end

    def flag_width
        @flags.map(&:width).max
    end

    def args_width
        @arguments.map(&:width).max
    end

    def usage
        str = File.basename __FILE__
        str += " #{@arguments.map { |a| "<#{a}>" }.join ', '}" unless @arguments.empty?
        str += ' [flags]' unless @flags.empty?
        str
    end

    def help
        puts @title
        puts "Version: #{@version}"

        unless @description.empty?
            puts ''
            puts @description
        end

        puts ''
        puts 'Usage:'
        puts "  #{usage}"

        unless @arguments.empty?
            puts ''
            puts 'Arguments:'
            @arguments.each do |arg|
                puts "  #{arg.to_s.ljust(args_width)}  #{arg.description}"
            end
        end

        return if @flags.empty?

        puts ''
        puts 'Options:'
        @flags.each do |flag|
            puts "  #{flag.to_s(flag_width)}"
        end
    end
end
