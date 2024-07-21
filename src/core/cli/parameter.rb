# frozen_string_literal: true

class CliParameter
    attr_reader :short, :long, :description, :type

    def initialize(short, long, type, description)
        @short       = short
        @long        = long
        @type        = type
        @description = description
        freeze
    end

    def match(arg)
        ["-#{@short}", "--#{@long}"].include?(arg)
    end

    def width
        "-#{@short}, --#{@long}".length
    end

    def to_s(width = 0)
        "-#{@short}, --#{@long}".ljust(width) + "  (#{@type}) #{@description}"
    end

    def symbol
        @long.gsub(/^-+/, '').gsub('-', '_').to_sym
    end
end
