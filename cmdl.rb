# frozen_string_literal: true

require_relative 'cmdlparser'
require_relative 'network'

def exit(string)
    string == 'exit' || string == 'quit' || string == 'q'
end

def prompt(text)
    print text
    gets.chomp
end

def cmdl_file(filename)
    logger = Logger.new($stdout, level: Logger::ERROR)

    parser = CmdlParser.new(Logger::ERROR)

    string = File.read(filename)
    tree = parser.parse(string)
    blueprint = tree.evaluate

    if blueprint.nil?
        logger.error('Tree evaluation failed. Exiting.')
        return
    end

    network = Network.new(blueprint, scope_suffix = '', local_suffix = '', log_level = Logger::ERROR)
    network.create
    network.print
end

def cmdl_prompt
    parser = CmdlParser.new(Logger::ERROR)
    bp_global = Blueprint.new 'global'

    string = prompt '> '

    until exit(string)
        parser.parse(string).evaluate(bp_global).print
        # parser.parse(string).print

        string = prompt '> '
    end
end

if ARGV.length.positive?
    cmdl_file(ARGV[0])
else
    cmdl_prompt
end
