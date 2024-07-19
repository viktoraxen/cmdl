require_relative 'synthesize'
require_relative 'simulate'

def run(opts)
    filename = opts[:filename]

    network = synthesize(filename, opts)

    simulation_interface(network, opts)
end
