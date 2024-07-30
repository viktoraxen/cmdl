# frozen_string_literal: true

require_relative 'cmdl_errors'

#
# General
#

def assert_not_reached(info = nil)
    raise UnreachableCodeError,
          "This code should not be reached (#{info})."
end

#
# Assignment
#

def assert_valid_assignment(scope, receiver_refs, value_refs)
    rec_num = receiver_refs.size
    val_num = value_refs.size

    assert_signals_declared(scope, receiver_refs + value_refs)

    unless rec_num == val_num
        raise AssignmentNumberMismatchError,
              "Number of receivers (#{rec_num}) does not match number of values (#{val_num})."
    end

    receiver_refs.zip(value_refs) do |receiver, value|
        rec_width = scope.template.signal_reference_width(receiver)
        val_width = scope.template.signal_reference_width(value)

        unless !(val_width && rec_width) || val_width == rec_width
            raise AssignmentWidthMismatchError,
                  "Width of receiver #{receiver} (#{rec_width}) does not match width of value #{value} (#{val_width})."
        end
    end

    receiver_refs.map { |r| assert_valid_subscript(scope, r) }
end

#
# Component
#

def assert_valid_signature(sig_id, input_refs, output_refs)
    invalid_inputs = _get_invalid_widths(input_refs)
    invalid_outputs = _get_invalid_widths(output_refs)

    unless sig_id[0] == sig_id[0].upcase
        raise SignatureInvalidIdentifierError,
              "Invalid component identifier: #{sig_id}. Component identifiers must be capitalized."
    end

    unless invalid_inputs.empty?
        raise SignatureInputInvalidWidthError,
              "Invalid signal widths for inputs of component #{sig_id}: #{_info_string(invalid_inputs)}"
    end

    unless invalid_outputs.empty?
        raise SignatureOutputInvalidWidthError,
              "Invalid signal widths for outputs of component #{sig_id}: #{_info_string(invalid_outputs)}"
    end

    ids = (input_refs + output_refs).map(&:id)

    ids.each do |id|
        unless ids.count(id) == 1
            raise SignatureDuplicateSignalError,
                  "Duplicate signal identifiers for component #{sig_id}: #{id}"
        end
    end
end

def _info_string(invalid_widths)
    invalid_widths.map { |id, width| "#{id} (#{width})" }.join(', ')
end

#
# Connection
#

def assert_valid_connection(connection, scope)
    # TODO: Implement, equal number of input, equal number of outputs, same width
    # assert_valid_scope scope
end

#
# Constraint
#

def assert_valid_constraint(constraint)
    raise ConstraintNullError, 'Constraint is null.' if constraint.nil?

    if constraint.inputs.nil? || constraint.inputs.empty?
        raise ConstraintInvalidInputsError,
              "Invalid inputs for #{constraint.name} (#{constraint.inputs})."
    end

    if constraint.outputs.nil? || constraint.outputs.empty?
        raise ConstraintInvalidOutputsError,
              "Invalid outputs for #{constraint.name} (#{constraint.outputs})."
    end

    assert_valid_gate_operation(constraint.operation)
end

def assert_valid_gate_operation(operation)
    return unless operation.nil?

    raise ConstraintInvalidOperationError,
          'Null operation'
end

#
# Declaration
#

def assert_valid_declaration(scope, declarators)
    declarators.each do |declarator|
        unless _width_valid?(declarator.width)
            raise DeclarationInvalidWidthError,
                  "Invalid signal width for declarator #{declarator.id}: #{declarator.width}"
        end
    end

    ids = declarators.map(&:id)

    ids.each do |id|
        unless ids.count(id) == 1
            raise DeclarationDuplicateSignalIdentifierError,
                  "Duplicate signal identifiers in scope #{scope.id}: #{id}"
        end

        if scope.template.signal_declared? id
            raise DeclarationSignalAlreadyDefinedError,
                  "Signal identifier #{id} already defined in scope #{scope.id}."
        end
    end
end

#
# Expressions
#

def assert_valid_component_expression(scope, comp_id, input_refs)
    component_scope = scope.find_scope(comp_id)

    if component_scope.nil?
        raise UnknownComponentError,
              "Could not find component #{comp_id} from scope #{scope.id}."
    end

    assert_signals_declared(scope, input_refs)

    component_inputs = component_scope.template.inputs.map(&:first)

    component_num_inputs = component_inputs.size
    num_inputs = input_refs.size

    unless num_inputs == component_num_inputs
        raise ExpressionComponentInputNumberMismatchError,
              "Given number of inputs (#{num_inputs}) does not match component #{comp_id} input width (#{component_num_inputs})!"
    end

    input_refs.zip(component_inputs) do |input, component_input|
        input_width = scope.template.signal_reference_width(input)
        component_width = component_scope.template.signal_width(component_input)

        unless (input_width.nil? || component_width.nil?) || input_width == component_width
            raise ExpressionComponentInputWidthMismatchError,
                  "Width of input #{input} (#{input_width}) does not match width of component #{comp_id} input #{component_input} (#{component_width})."
        end
    end
end

def assert_valid_binary_gate_expression(scope, lh_refs, rh_refs, operation)
    lh_size = lh_refs.size
    rh_size = rh_refs.size

    unless lh_size == rh_size
        raise ExpressionBinaryInputNumberMismatchError,
              "Number of left hand operands (#{lh_size}) does not match number of right hand operands (#{rh_size})."
    end

    assert_signals_declared(scope, lh_refs + rh_refs)

    return if operation == 'cat'

    lh_refs.zip(rh_refs) do |lh, rh|
        lh_width = scope.template.signal_reference_width(lh)
        rh_width = scope.template.signal_reference_width(rh)

        unless (lh_width.nil? || rh_width.nil?) || lh_width == rh_width
            raise ExpressionBinaryInputWidthMismatchError,
                  "Width of left hand operand (#{lh_width}) does not match width of right hand operand (#{rh_width})."
        end
    end

    return if ['and', 'or', 'not', 'eq'].include?(operation)

    raise ExpressionInvalidOperationError,
          "Invalid operation: #{operation}, allowed operations are 'and', 'or', 'not'."
end

def assert_valid_nor_expression(scope, lf_refs, rh_refs)
    assert_signals_declared(scope, lf_refs + rh_refs)

    assert_valid_binary_gate_expression(scope, lf_refs, rh_refs, 'or')
end

def assert_valid_nand_expression(scope, lf_refs, rh_refs)
    assert_signals_declared(scope, lf_refs + rh_refs)

    assert_valid_binary_gate_expression(scope, lf_refs, rh_refs, 'and')
end

def assert_valid_unary_expression(scope, input_refs, operation)
    assert_signals_declared(scope, input_refs)

    return if ['not'].include?(operation)

    raise ExpressionInvalidOperationError,
          "Invalid unary operation: #{operation}, allowed operations are 'not'."
end

#
# Gate
#

def assert_valid_unary_gate(connection)
    inputs = connection.inputs
    input_size = inputs.size

    return if input_size == 1

    raise GateUnaryInputError,
          "Unary gate #{connection.operation} requires exactly 1 input, found #{input_size} (#{inputs.join(', ')}"

    # TODO: More checks?
end

def assert_valid_binary_gate(connection)
    # TODO: Implement
end

def assert_valid_merge_gate(connection)
    # TODO: Implement
end

#
# Identifer
#

def assert_valid_identifier(id)
    return unless ['not', 'and', 'or', 'xor', 'nor', 'nand', 'xnor'].include?(id)

    raise ForbiddenIdentifierError,
          "Identifier '#{id}' is forbidden."
end

#
# Scope
#

def assert_valid_scope_node(node)
    unless node.is_a? ScopeNode
        raise ScopeNodeError,
              "Not a scope node: #{node.class}"
    end

    if node.children.select { |c| c.is_a? ComponentSignatureNode }.size > 1
        raise ScopeSignatureError,
              'Scope node must contain at most one component signature.'
    end

    return unless node.children.select { |c| c.is_a? CodeBlockNode }.size > 1

    raise ScopeCodeBlockError,
          'Scope node must contain at most one code block.'
end

def assert_valid_subscope(scope, subscope)
    return unless scope.contains_scope? subscope.id

    raise ScopeDuplicateSubscopeError,
          "Duplicate scope identifier in scope #{scope.id}: #{subscope.id}"
end

def assert_valid_scope(scope)
    raise ScopeNullError, 'Scope is null.' if scope.nil?

    assert_valid_template scope.template
end

#
# Signal
#

def assert_signal_exists(scope, signal_id)
    return if scope.template._signal_exists? signal_id

    raise SignalNotFoundError,
          "Signal #{signal_id} not found in scope #{scope.id}."
end

#
# Subscript
#

def assert_valid_subscript(scope, signal_ref, subscript = nil)
    subscript ||= signal_ref.subscript

    if subscript.nil?
        raise SubscriptNullError,
              "Subscript is null for signal #{signal_ref.id}."
    end

    assert_signal_declared(scope, signal_ref)

    signal_id    = signal_ref.id
    signal_width = scope.template.signal_width signal_id

    unless subscript.start.nil?
        start_reach = subscript.start.abs
        start_reach += 1 if subscript.start >= 0

        if start_reach > signal_width
            raise SubscriptIndexOutOfBoundsError,
                  "Index #{subscript.start} out of bounds for signal #{signal_id} with width #{signal_width}."
        end
    end

    return if subscript.stop.nil?

    end_reach = subscript.stop.abs - 1
    end_reach += 1 if subscript.stop >= 0

    return unless end_reach > signal_width

    raise SubscriptIndexOutOfBoundsError,
          "Index #{subscript.stop} out of bounds for signal #{signal_id} with width #{signal_width}."
end

def assert_valid_span_values(start, stop)
    if start.nil? && stop.nil?
        raise SpanNullIndexError,
              'Start and end of span cannot both be null.'
    end

    if (!start.nil? && !stop.nil?) &&
       ((start >= 0 && stop >= 0 && start > stop) ||
       (start.negative? && stop.negative? && start > stop))
        raise SpanInvalidRangeError,
              "Start index must be before end index: #{start}..#{stop}."
    end
end

#
# Synchronized
#

def assert_valid_synchronized(signature, sync)
    signature.inputs.each do |input|
        next unless sync == input

        raise SignatureDuplicateSignalError,
              "Duplicate signal identifiers for component #{signature.id}: #{sync}"
    end
end

#
# Template
#

def assert_valid_template(template)
    raise TemplateNullError, 'Template is null.' if template.nil?

    name = template.scope.full_name
    undeclared_signals = template.undeclared_signals

    return if undeclared_signals.empty?

    raise TemplateUndeclaredSignalsError,
          "Template #{name} contains undeclared signals: #{undeclared_signals.join(', ')}"
end

def assert_signals_declared(scope, refs)
    refs.each do |ref|
        assert_signal_declared(scope, ref)
    end
end

def assert_signal_declared(scope, ref)
    return if scope.template.signal_declared? ref.id

    raise UndeclaredSignalError,
          "Signal #{ref.id} is not declared in scope #{scope.id}."
end

#
# Width
#

def _get_invalid_widths(reference_list)
    invalid_widths = {}

    reference_list.each do |reference|
        invalid_widths[reference.id] = reference.width unless _width_valid?(reference.width)
    end

    invalid_widths
end

def _width_valid?(width)
    width.nil? || width.positive?
end
