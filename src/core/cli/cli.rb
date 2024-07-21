# frozen_string_literal: true

require_relative 'flag'
require_relative 'argument'
require_relative 'parameter'

class CliApp
    def initialize(title, version, description = '')
        @title       = title
        @version     = version
        @description = description
        @arguments   = []
        @parameters  = []
        @flags       = []
    end

    def parse(argv)
        return help if argv.empty?

        args = @flags.to_h { |f| [f.symbol, false] }
        args = args.merge(@parameters.to_h { |p| [p.symbol, nil] })
        args = args.merge(@arguments.to_h { |a| [a.symbol, nil] })

        until argv.empty?
            arg = argv.shift

            if arg.start_with?('-')
                @flags.each do |flag|
                    args[flag.symbol] = true if flag.match(arg)
                end
                @parameters.each do |param|
                    next unless param.match(arg)

                    val = argv.shift
                    val = case param.type.to_s
                          when 'Integer'
                              val.to_i
                          when 'Float'
                              val.to_f
                          else
                              val
                          end

                    puts "Missing value for parameter #{arg}" unless !val.nil? || !val.start_with?('-')
                    args[param.symbol] = val
                end
            else
                if @arguments.empty?
                    puts "Unknown argument: #{arg}"
                    next
                end
                args[@arguments.shift.symbol] = arg
            end
        end

        puts "Unknown argument: #{argv.first}" unless argv.empty?

        yield args
    end

    def add_argument(name, description)
        @arguments << CliArgument.new(name, description)
    end

    def add_parameter(short, long, type, description)
        @parameters << CliParameter.new(short, long, type, description)
    end

    def add_flag(short, long, description)
        @flags << CliFlag.new(short, long, description)
    end

    def flag_width
        @flags.map(&:width).max
    end

    def params_width
        @parameters.map(&:width).max
    end

    def args_width
        @arguments.map(&:width).max
    end

    def usage
        str = File.basename __FILE__
        str += " #{@arguments.map { |a| "<#{a.name}>" }.join ' '}" unless @arguments.empty?
        str += ' [options]' unless @flags.empty?
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
                puts "  #{arg.to_s(args_width)}"
            end
        end

        return if @parameters.empty? && @flags.empty?

        puts ''
        puts 'Options:'

        unless @parameters.empty?
            puts '  Parameters:'
            @parameters.each do |arg|
                puts "    #{arg.to_s(args_width)}"
            end
        end

        return if @flags.empty?

        puts '' unless @parameters.empty?
        puts '  Flags:'
        @flags.each do |flag|
            puts "    #{flag.to_s(flag_width)}"
        end
    end
end
