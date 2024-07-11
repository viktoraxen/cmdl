# frozen_string_literal: true

class AssignmentNumberMismatchError < StandardError
end

class AssignmentWidthMismatchError < StandardError
end

class ComponentDuplicateInputError < StandardError
end

class ComponentDuplicateSignatureSignalError < StandardError
end

class ComponentInputInvalidWidthError < StandardError
end

class ComponentOutputInvalidWidthError < StandardError
end

class ComponentNotFoundError < StandardError
end

class ConstraintNullError < StandardError
end

class ConstraintInvalidInputsError < StandardError
end

class ConstraintInvalidOutputsError < StandardError
end

class ConstraintInvalidOperationError < StandardError
end

class DeclarationInvalidWidthError < StandardError
end

class DeclarationDuplicateSignalIdentifierError < StandardError
end

class DeclarationSignalAlreadyDefinedError < StandardError
end

class DuplicateComponentIdentifierError < StandardError
end

class DuplicateSignalIdentifierError < StandardError
end

class ExpressionBinaryInputNumberMismatchError < StandardError
end

class ExpressionBinaryInputWidthMismatchError < StandardError
end

class ExpressionComponentInputNumberMismatchError < StandardError
end

class ExpressionComponentInputWidthMismatchError < StandardError
end

class ExpressionInvalidOperationError < StandardError
end

class ForbiddenIdentifierError < StandardError
end

class GateUnaryInputError < StandardError
end

class InvalidComponentError < StandardError
end

class InvalidDeclarationError < StandardError
end

class InvalidExpressionError < StandardError
end

class ParseError < StandardError
end

class ScopeDuplicateSubscopeError < StandardError
end

class ScopeNullError < StandardError
end

class ScopeNodeError < StandardError
end

class ScopeSignatureError < StandardError
end

class ScopeCodeBlockError < StandardError
end

class ScopeTemplateNullError < StandardError
end

class SignalInvalidWidthError < StandardError
end

class SpanInvalidRangeError < StandardError
end

class SubscriptIndexOutOfBoundsError < StandardError
end

class TemplateUndeclaredSignalsError < StandardError
end

class UnknownComponentError < StandardError
end

class ValidationResultError < StandardError
end
