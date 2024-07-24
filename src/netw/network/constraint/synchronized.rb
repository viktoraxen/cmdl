require_relative 'core'

class SynchronizedConstraint < Constraint
    def initialize(name, sync, input, output)
        super(name, [input], output)
        @sync = sync
        @sync.add_connection(self)

        @last_sync = @sync.value

        @type = 'synchronized'
    end

    def new_value(queue = nil)
        return if @sync.nil?

        last_sync = @last_sync
        @last_sync = @sync.value

        super if last_sync == false && @sync.value
    end

    def expression
        "#{type_s} #{@inputs[0].name}"
    end
end

class SynchronizedAssignGate < SynchronizedConstraint
    def initialize(name, sync, input, output)
        @operation = -> { @inputs[0].value }

        super

        @type = 'synchronized_assign'
    end
end
