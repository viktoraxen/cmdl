# frozen_string_literal: true

require_relative '../netw/parser/cmdlparser'
require_relative '../netw/network/network'
require_relative '../core/utils/print'

def synthesize(filename, opts)
    log_level = opts[:logging] ? Logger::DEBUG : Logger::ERROR

    Log.initialize(log_level)

    parser = CmdlParser.new(Logger::ERROR)

    string = File.read(filename)
    tree   = parser.parse(string)

    root_scope = tree.evaluate
    network    = root_scope.synthesize
    result     = network.state

    [tree, root_scope, network, result]
end
