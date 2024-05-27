#!/usr/bin/env ruby

require 'logger'

class Log
    @@logger = Logger.new($stdout)

    def Log.initialize(level)
        @@logger.level = level
        @@logger.formatter = proc do |severity, datetime, progname, msg|
            date_format = datetime.strftime('%H:%M:%S')
            "#{date_format} #{severity.ljust(5)}: #{msg}\n"
        end
    end

    def Log.debug(message)
        @@logger.debug(message)
    end

    def Log.info(message)
        @@logger.info(message)
    end

    def Log.warn(message)
        @@logger.warn(message)
    end

    def Log.error(message)
        @@logger.error(message)
    end

    def Log.fatal(message)
        @@logger.fatal(message)
    end

    def Log.unknown(message)
        @@logger.unknown(message)
    end
end
