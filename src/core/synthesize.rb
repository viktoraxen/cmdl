# frozen_string_literal: true

require_relative '../netw/parser/cmdlparser'
require_relative '../netw/network/network'
require_relative 'utils/print'

def synthesize(filename, opts)
    opts[:network_print] = true if opts[:full_network_print] || opts[:deep_network_print] || (!opts[:syntax_tree_print] && !opts[:template_print])
    log_level = opts[:logging] ? Logger::DEBUG : Logger::ERROR

    Log.initialize(log_level)

    parser = CmdlParser.new(Logger::ERROR)

    string = File.read(filename)
    tree   = parser.parse(string)

    root_scope = tree.evaluate
    network    = root_scope.synthesize
    result     = network.state

    tree.print       if opts[:syntax_tree_print]
    root_scope.print if opts[:template_print]

    nw_print      = opts[:network_print]
    full_nw_print = opts[:full_network_print]
    deep_nw_print = opts[:deep_network_print]

    network.print(full_nw_print, deep_nw_print) if nw_print

    print_h result if opts[:result_print]

    network
end
