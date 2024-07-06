<< Single declare
signal a

<< Forbidden identifer and
< fail: ForbiddenIdentifierError
signal and

<< Forbidden identifer or
< fail: ForbiddenIdentifierError
signal or

<< Forbidden identifer not
< fail: ForbiddenIdentifierError
signal not

<< Double declare
signal b, c

<< With width
signal d: 2

<< Width omitted
< fail: ParseError
signal d:

<< Width zero
< fail: SignalInvalidWidthError
signal d: 0

<< Width negative
< fail: SignalInvalidWidthError
signal d: -1

<< Double with width
signal e: 3, f: 4

<< Mixed width
signal a, b:3, c: 4, d: 7, e

<< Mixed width, one invalid
< fail: SignalInvalidWidthError
signal a, b:3, c: 4, d: 0, e

<< All characters in name
signal abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_

<< Multidigit width with leading 1
signal a: 1322

<< Invalid characters in name
< fail: ParseError
signal fsd,.,.

<< Duplicate identifier
< fail: DuplicateSignalIdentifierError
signal a, a
