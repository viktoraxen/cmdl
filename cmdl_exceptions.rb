# frozen_string_literal: true
#
#!/usr/bin/env ruby

class UndeclaredSignalsException < StandardError
    def initialize(wires, scope = nil)
        msg = "Undefined signals: #{wires.map(&:name).join(', ')}"
        msg += " in scope #{scope.name}" if scope
        super(msg)
    end
end
