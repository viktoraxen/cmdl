<< Single declare
signal a

<< Forbidden identifer and
< until: evaluate
< fail: ForbiddenIdentifierError
signal and

<< Forbidden identifer or
< until: evaluate
< fail: ForbiddenIdentifierError
signal or

<< Forbidden identifer not
< until: evaluate
< fail: ForbiddenIdentifierError
signal not

<< Double declare
signal b, c

<< With width
< d: bxx
signal d: 2

<< Width omitted
< until: parse
< fail: ParseError
signal d:

<< Width zero
< until: evaluate
< fail: DeclarationInvalidWidthError
signal d: 0

<< Width negative
< until: evaluate
< fail: DeclarationInvalidWidthError
signal d: -1

<< Double with width
< e: bxxx
< f: bxxxx
signal e: 3, f: 4

<< Mixed width
< a: bx
< b: bxxx
< c: bxxxx
< d: bxxxxxxx
< e: bx
signal a, b:3, c: 4, d: 7, e

<< Mixed width, one invalid
< until: evaluate
< fail: DeclarationInvalidWidthError
signal a, b:3, c: 4, d: 0, e

<< All characters in name
< abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_: bx
signal abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_

<< Multidigit width with leading 1
< a: 1: 1322
signal a: 1322 <= 1: 1322

<< Invalid characters in name
< until: parse
< fail: ParseError
signal fsd,.,.

<< Duplicate identifier
< until: evaluate
< fail: DeclarationDuplicateSignalIdentifierError
signal a, a
