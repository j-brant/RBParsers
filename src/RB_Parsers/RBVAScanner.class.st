Class {
	#name : #RBVAScanner,
	#superclass : #RBOptimizedScanner,
	#category : #'RB_Parsers'
}

{ #category : #'private-scanning' }
RBVAScanner >> namespaceSeparatorCharacter [
	^$:
]

{ #category : #'private-scanning' }
RBVAScanner >> scanExtendedLiterals [
	| token |
	self step.
	token := characterType == #alphabetic
		ifTrue: [self scanSymbol]
		ifFalse: [
			characterType == #binary
				ifTrue: [(self scanBinary: RBLiteralToken) stop: self previousStepPosition]
				ifFalse: [
					currentCharacter == $'
						ifTrue: [self scanStringSymbol]
						ifFalse: [
							currentCharacter == $(
								ifTrue: [
									self step.
									^RBOptimizedToken start: tokenStart]]]].
	token isNil ifTrue: [self scannerError: 'Expecting an extended literal'].
	token value: ((Smalltalk at: #EsAtom) intern: token value asString).
	^token
]

{ #category : #'private-scanning' }
RBVAScanner >> scanNameSpaceName [
	stream peek == self namespaceSeparatorCharacter ifFalse: [^nil].
	buffer next: 2 put: self namespaceSeparatorCharacter.
	self step.
	self step.
	self scanName.
	currentCharacter == self namespaceSeparatorCharacter ifTrue: [self scanNameSpaceName].
	^RBIdentifierToken value: buffer contents start: tokenStart
]
