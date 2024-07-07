# frozen_strin_literal: true

require_relative '../error/cmdlerrors'

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

    unless rec_num == val_num
        raise AssignmentNumberMismatchError,
              "Number of receivers (#{rec_num}) does not match number of values (#{val_num})."
    end

    receiver_refs.zip(value_refs) do |receiver, value|
        rec_width = scope.template.signal_reference_width(receiver)
        val_width = scope.template.signal_reference_width(value)

        unless !(val_width && rec_width) || val_width == rec_width
            raise AssignmentWidthMismatchError,
                  "Width of receiver (#{rec_width}) does not match width of value (#{val_width})."
        end
    end
end

#
# Component
#

def assert_valid_component_signature(comp_id, input_refs, output_refs)
    invalid_inputs = _get_invalid_widths(input_refs)
    invalid_outputs = _get_invalid_widths(output_refs)

    unless invalid_inputs.empty?
        raise ComponentInputInvalidWidthError,
              "Invalid signal widths for inputs of component #{comp_id}: #{_info_string(invalid_inputs)}"
    end

    unless invalid_outputs.empty?
        raise ComponentOutputInvalidWidthError,
              "Invalid signal widths for outputs of component #{comp_id}: #{_info_string(invalid_outputs)}"
    end

    ids = (input_refs + output_refs).map(&:id)

    ids.each do |id|
        unless ids.count(id) == 1
            raise ComponentDuplicateSignatureSignalError,
                  "Duplicate signal identifiers for component #{comp_id}: #{id}"
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
    if operation.nil?
        raise ConstraintInvalidOperationError,
            "Null operation"
    end
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
                  "Duplicate signal identifiers in declaration: #{id}"
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

    component_num_inputs = component_scope.template.num_inputs
    num_inputs = input_refs.size

    unless num_inputs == component_num_inputs
        raise ExpressionComponentInputNumberMismatchError,
              "Given number of inputs (#{num_inputs}) does not match component #{comp_id} input width (#{component_num_inputs})!"
    end

    component_inputs = component_scope.template.inputs.map(&:first)

    input_refs.zip(component_inputs) do |input, component_input|
        input_width = scope.template.signal_reference_width(input)
        component_width = component_scope.template.signal_width(component_input)

        unless (input_width.nil? || component_width.nil?) || input_width == component_width
            raise ExpressionComponentInputWidthMismatchError,
                  "Width of input (#{input_width}) does not match width of component input (#{component_width})."
        end
    end
end

def assert_valid_binary_expression(scope, lh_refs, rh_refs, operation)
    lh_size = lh_refs.size
    rh_size = rh_refs.size

    unless lh_size == rh_size
        raise ExpressionBinaryInputNumberMismatchError,
              "Number of left hand operands (#{lh_size}) does not match number of right hand operands (#{rh_size})."
    end

    lh_refs.zip(rh_refs) do |lh, rh|
        lh_width = scope.template.signal_reference_width(lh)
        rh_width = scope.template.signal_reference_width(rh)

        unless (lh_width.nil? || rh_width.nil?) || lh_width == rh_width
            raise ExpressionBinaryInputWidthMismatchError,
                  "Width of left hand operand (#{lh_width}) does not match width of right hand operand (#{rh_width})."
        end
    end

    unless ['and', 'or', 'not'].include?(operation)
        raise ExpressionInvalidOperationError,
              "Invalid operation: #{operation}, allowed operations are 'and', 'or', 'not'."
    end
end

#
# Gate
#
 
def assert_valid_unary_gate(connection)
    inputs = connection.inputs
    input_size = inputs.size

    unless input_size == 1
        raise GateUnaryInputError,
              "Unary gate #{connection.operation} requires exactly 1 input, found #{input_size} (#{inputs.join(', ')}"
    end

    # TODO: More checks?
end

def assert_valid_binary_gate(connection)
    # TODO: Implement
end

#
# Identifer
#

def assert_valid_identifier(id)
    if ['not', 'and', 'or'].include?(id)
        raise ForbiddenIdentifierError, 
            "Identifier '#{id}' is forbidden."
    end
end

#
# Scope
#

def assert_valid_subscope(scope, subscope)
    if scope.contains_scope? subscope.id
        raise ScopeDuplicateSubscopeError,
              "Duplicate scope identifier in scope #{scope.id}: #{subscope.id}"
    end
end

def assert_valid_scope(scope, id = nil)
    if scope.nil?
        raise ScopeNullError, "Scope #{id} is null."
    end

    assert_valid_template scope.template
end

#
# Subscript
#

def assert_valid_span(start, stop)
    if start.nil? && stop.nil?
        raise SpanNullIndexError,
            'Start and end of span cannot both be null.'
    end

    if (!start.nil? && !stop.nil?) && 
        ((start >= 0 && stop >= 0 && start > stop) || 
        (start.negative? && stop.negative? && start > stop))
        raise SpanInvalidRangeError,
            "Start index must be before en index: #{start}..#{stop}."
    end
end

#
# Template
#

def assert_valid_template(template)
    raise TemplateNullError, 'Template is null.' if template.nil?

    name = template.scope.full_name
    undeclared_signals = template.undeclared_signals

    unless undeclared_signals.empty?
        raise TemplateUndeclaredSignalsError,
            "Template #{name} contains undeclared signals: #{undeclared_signals.join(', ')}"
    end
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
