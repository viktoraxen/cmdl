require_relative 'cmdlparser'
require_relative 'log'
require_relative 'network'

Log.initialize(Logger::INFO)

parser = CmdlParser.new(Logger::INFO)

string = File.read('mux.cmdl')

tree = parser.parse(string)
# tree.print

root = tree.evaluate(Scope.new('root'))
# root.print

network = Network.create_network(root)
network.print
