Class {
	#name : #RBVWScanner,
	#superclass : #RBScanner,
	#category : #'RB_Parsers'
}

{ #category : #'private - scanning' }
RBVWScanner >> scanIdentifierOrKeyword [
	| name |
	self scanName.
	currentCharacter == $.
		ifTrue: [ self scanNameSpaceName ifNotNil: [ :token | ^ token ] ].
	(currentCharacter = $: and: [ stream peek ~= $= ])
		ifTrue: [ ^ self scanKeyword ].
	name := buffer contents.
	name = 'true'
		ifTrue: [ ^ RBLiteralToken
				value: true
				start: tokenStart
				stop: self previousStepPosition ].
	name = 'false'
		ifTrue: [ ^ RBLiteralToken
				value: false
				start: tokenStart
				stop: self previousStepPosition ].
	name = 'nil'
		ifTrue: [ ^ RBLiteralToken
				value: nil
				start: tokenStart
				stop: self previousStepPosition ].
	^ RBIdentifierToken value: name start: tokenStart
]

{ #category : #'private - scanning' }
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

{ #category : #'private - scanning' }
RBVWScanner >> scanNameSpaceName [
	(stream atEnd or: [ (self classify: stream peek) ~~ #alphabetic ])
		ifTrue: [ ^ nil ].
	buffer nextPut: $..
	self step.
	self scanName.
	currentCharacter == $. ifTrue: [ self scanNameSpaceName ].
	^ RBIdentifierToken value: buffer contents start: tokenStart
]

{ #category : #'private - scanning' }
RBVWScanner >> scanQualifiedReference [
	| nameToken |
	self step.	"{"
	self stripSeparators.
	nameToken := self scanIdentifierOrKeyword.
	(nameToken isIdentifier and: [nameToken value notEmpty]) 
		ifFalse: [self scannerError: 'Invalid name in qualified reference'].
	self stripSeparators.
	currentCharacter == $} ifFalse: [self scannerError: '} expected'].
	self step.	"}"
	^RBLiteralToken 
		value: (RBQualifiedName pathString: nameToken value)
		start: tokenStart
		stop: self previousStepPosition
]
