# frozen_string_literal: true

# !/usr/bin/env ruby

require 'logger'
require 'colorize'

class Log
    @@colors = [
        :light_cyan,
        :light_blue,
        :light_magenta,
        :light_green,
        :light_yellow
    ]

    @@logger = Logger.new($stdout)

    def Log.initialize(level)
        @@logger.level = level
        @@logger.formatter = proc do |severity, datetime, _, msg|
            date_format = datetime.strftime('%H:%M:%S')
            "#{date_format} #{severity.ljust(5)}: #{msg}\n"
        end
    end

    def Log.colorize(*args)
        message = ''

        args.each_with_index do |arg, i|
            message += "#{arg.to_s.colorize(@@colors[i % @@colors.size])} "
        end

        message
    end

    def Log.debug(*args)
        @@logger.debug(Log.colorize(*args))
    end

    def Log.info(*args)
        @@logger.info(Log.colorize(*args))
    end

    def Log.warn(*args)
        @@logger.warn(Log.colorize(*args))
    end

    def Log.error(*args)
        @@logger.error(Log.colorize(*args))
    end

    def Log.fatal(*args)
        @@logger.fatal(Log.colorize(*args))
    end

    def Log.unknown(*args)
        @@logger.unknown(Log.colorize(*args))
    end
end
