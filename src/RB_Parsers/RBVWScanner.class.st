Class {
	#name : 'RBVWScanner',
	#superclass : 'OCScanner',
	#category : 'RB_Parsers',
	#package : 'RB_Parsers'
}

{ #category : 'private - scanning' }
RBVWScanner >> scanIdentifierOrKeyword [
	| name |
	self scanName.
	currentCharacter == $.
		ifTrue: [ self scanNameSpaceName ifNotNil: [ :token | ^ token ] ].
	(currentCharacter = $: and: [ stream peek ~= $= ])
		ifTrue: [ buffer nextPut: currentCharacter.
			self step.
			name := buffer contents.
			^ OCKeywordToken value: name start: tokenStart ].
	name := buffer contents.
	(self scanNamedLiteral: name) ifNotNil: [ :token | ^ token ].
	^ OCIdentifierToken value: name start: tokenStart
]

{ #category : 'private - scanning' }
RBVWScanner >> scanLiteral [
	self step.
	self stripSeparators.
	characterType = #alphabetic ifTrue: [ ^ self scanSymbol ].
	characterType = #binary
		ifTrue: [ ^ self scanLiteralBinary stop: self previousStepPosition ].
	currentCharacter = $' ifTrue: [ ^ self scanStringSymbol ].
	(currentCharacter = $( or: [ currentCharacter = $[ ])
		ifTrue: [ ^ self scanLiteralArrayToken ].
	currentCharacter == ${ ifTrue: [ ^ self scanQualifiedReference ].
	^ (self scanError: 'Expecting a literal type') value: '#'
]

{ #category : 'private - scanning' }
RBVWScanner >> scanNameSpaceName [
	(stream atEnd or: [ (self classify: stream peek) ~~ #alphabetic ])
		ifTrue: [ ^ nil ].
	buffer nextPut: $..
	self step.
	self scanName.
	currentCharacter == $. ifTrue: [ self scanNameSpaceName ].
	^ OCIdentifierToken value: buffer contents start: tokenStart
]

{ #category : 'private - scanning' }
RBVWScanner >> scanQualifiedReference [
	| nameToken |
	self step.	"{"
	self stripSeparators.
	nameToken := self scanIdentifierOrKeyword.
	(nameToken isIdentifier and: [ nameToken value notEmpty ])
		ifFalse: [ self scanError: 'Invalid name in qualified reference' ].
	self stripSeparators.
	currentCharacter == $} ifFalse: [ self scanError: '} expected' ].
	self step.	"}"
	^ OCLiteralToken
		value: (RBQualifiedName pathString: nameToken value)
		start: tokenStart
		stop: self previousStepPosition
]
