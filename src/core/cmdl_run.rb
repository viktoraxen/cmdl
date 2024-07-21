require_relative '../netw/synthesize'
require_relative '../sim/simulate'

def run(opts)
    circuit_file = opts[:circuit]

    tree, root_scope, network, result = synthesize(circuit_file, opts)

    tree.print       if opts[:syntax_tree_print]
    root_scope.print if opts[:template_print]

    nw_print       = opts[:network_print]
    full_nw_print  = opts[:full_network_print]
    nw_print_depth = opts[:print_depth] || 999
    deep_nw_print  = opts[:deep_network_print]

    network.print(full_nw_print, deep_nw_print, nw_print_depth) if nw_print

    print_h result if opts[:result_print]

    simulation_interface(network, opts)
end
