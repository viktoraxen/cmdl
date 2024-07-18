# frozen_string_literal: true

require_relative '../parser/cmdlparser'
require_relative '../network/network'

def cmdl_file(filename, flags)
    log_level = flags[:logging] ? Logger::DEBUG : Logger::ERROR

    Log.initialize(log_level)

    parser = CmdlParser.new(Logger::ERROR)

    string = File.read(filename)
    tree = parser.parse(string)
    tree.print if flags[:syntax_tree_print]

    root_scope = tree.evaluate
    root_scope.print if flags[:template_print]

    flags[:network_print] = true if flags[:full_network_print] || flags[:deep_network_print] || (!flags[:syntax_tree_print] && !flags[:template_print])

    network = root_scope.synthesize
    network.print(flags[:full_network_print], flags[:deep_network_print]) if flags[:network_print]

    # result = network.get_state
    # puts result
end
