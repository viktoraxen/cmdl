# frozen_string_literal: true

class CliFlag
    attr_reader :name, :short, :long, :description, :default

    def initialize(short, long, description)
        @short       = short
        @long        = long
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
        "-#{@short}, --#{@long}".ljust(width) + "  #{@description}"
    end

    def symbol
        @long.gsub(/^-+/, '').gsub('-', '_').to_sym
    end
end
