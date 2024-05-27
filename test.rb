require_relative 'cmdlparser'
require_relative 'log'

Log.initialize(Logger::DEBUG)

parser = CmdlParser.new(Logger::INFO)

string = File.read('test2.cmdl')
tree = parser.parse(string)
# tree.print
scope = tree.evaluate(Scope.new('root'))

scope.print
