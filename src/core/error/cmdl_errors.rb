# frozen_string_literal: true

class AssignmentNumberMismatchError < StandardError
end

class AssignmentUndeclaredReceiverError < StandardError
end

class AssignmentUndeclaredSignalError < StandardError
end

class AssignmentWidthMismatchError < StandardError
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

class ExpressionUndeclaredSignalError < StandardError
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

class SubscriptUndeclaredSignalError < StandardError
end

class SignatureDuplicateSignalError < StandardError
end

class SignatureInputInvalidWidthError < StandardError
end

class SignatureInvalidIdentifierError < StandardError
end

class SignatureOutputInvalidWidthError < StandardError
end

class TemplateUndeclaredSignalsError < StandardError
end

class UndeclaredSignalError < StandardError
end

class UnknownComponentError < StandardError
end

class UnknownSynchronizedError < StandardError
end

class UnreachableCodeError < StandardError
end

class ValidationResultError < StandardError
end
