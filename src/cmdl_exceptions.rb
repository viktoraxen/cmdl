# frozen_string_literal: true
#
#!/usr/bin/env ruby

class UndeclaredSignalsException < StandardError
    def initialize(wires, scope = nil)
        msg = "Undefined signal(s): #{wires.join(', ')}"
        msg += " in scope #{scope.name}" if scope
        super(msg)
    end
end

class DuplicateSignalDeclarationException < StandardError
    def initialize(wires, scope = nil)
        msg = "Duplicate declaration of signal(s): #{wires.join(', ')}"
        msg += " in scope #{scope.name}" if scope
        super(msg)
    end
end

class SignalReassignmentException < StandardError
    def initialize(wires, scope = nil)
        msg = "Reassignment of signal(s): #{wires.join(', ')}"
        msg += " in scope #{scope.name}" if scope
        super(msg)
    end
end

class DuplicateComponentException < StandardError
    def initialize(component, scope = nil)
        msg = "Duplicate component: #{component}"
        msg += " in scope #{scope.name}" if scope
        super(msg)
    end
end
