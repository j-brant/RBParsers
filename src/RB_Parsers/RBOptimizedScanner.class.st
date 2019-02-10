Class {
	#name : #RBOptimizedScanner,
	#superclass : #RBScanner,
	#category : #'RB_Parsers'
}

{ #category : #'private-scanning' }
RBOptimizedScanner >> basicScanNumber [
	| number isNegative |
	isNegative := false.
	currentCharacter == $- 
		ifTrue: 
			[isNegative := true.
			self step].
	number := self scanNumberWithoutExponent.
	^(isNegative ifTrue: [number negated] ifFalse: [number]) 
		* self scanExponentMultipler
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> namespaceSeparatorCharacter [
	^$.
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> scanExponentMultipler [
	| exponent isExpNegative position |
	currentCharacter == $e
		ifTrue: 
			[position := stream position.
			self step.
			(isExpNegative := currentCharacter == $-) ifTrue: [self step].
			exponent := self scanNumberOfBase: 10.
			exponent isNil
				ifTrue: 
					["Did not read a valid exponent, e must be start of a message send"

					stream position: position - 1.
					self step.
					exponent := 0]
				ifFalse: [isExpNegative ifTrue: [exponent := exponent negated]]]
		ifFalse: [exponent := 0].
	^10 raisedToInteger: exponent
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> scanExtendedLiterals [
	self step.
	currentCharacter == $(
		ifTrue:
			[self step.
			^RBOptimizedToken start: tokenStart].
	self scannerError: 'Expecting an extended literal'
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> scanIdentifierOrKeyword [
	| token name |
	self scanName.
	currentCharacter == self namespaceSeparatorCharacter
		ifTrue:
			[token := self scanNameSpaceName.
			token notNil ifTrue: [^token]].
	(currentCharacter == $: and: [stream peek ~~ $=]) ifTrue: [^self scanKeyword].
	name := buffer contents.
	name = 'true'
		ifTrue:
			[^RBLiteralToken
				value: true
				start: tokenStart
				stop: self previousStepPosition].
	name = 'false'
		ifTrue:
			[^RBLiteralToken
				value: false
				start: tokenStart
				stop: self previousStepPosition].
	name = 'nil'
		ifTrue:
			[^RBLiteralToken
				value: nil
				start: tokenStart
				stop: self previousStepPosition].
	^RBIdentifierToken value: name start: tokenStart
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> scanLiteral [
	self step.
	characterType == #alphabetic ifTrue: [^self scanSymbol].
	characterType == #binary ifTrue: [^(self scanBinary: RBLiteralToken) stop: self previousStepPosition].
	currentCharacter == $' ifTrue: [^self scanStringSymbol].
	('([' includes: currentCharacter) ifTrue: [^self scanLiteralArrayToken].
	currentCharacter == $# ifTrue: [^self scanExtendedLiterals].
	self scannerError: 'Expecting a literal type'
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> scanNameSpaceName [
	(stream atEnd or: [(self classify: stream peek) ~~ #alphabetic]) ifTrue: [^nil].
	buffer nextPut: $..
	self step.
	self scanName.
	currentCharacter == $. ifTrue: [self scanNameSpaceName].
	^RBIdentifierToken value: buffer contents start: tokenStart
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> scanNumber [
	| start number stop string currentPosition |
	start := stream position.
	number := self basicScanNumber.
	currentPosition := stream position.
	stop := self atEnd ifTrue: [currentPosition] ifFalse: [currentPosition - 1].
	stream position: start - 1.
	string := stream next: stop - start + 1.
	stream position: currentPosition.
	^RBNumberLiteralToken 
		value: number
		start: start
		stop: stop
		source: string
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> scanNumberOfBase: anInteger [ 
	"Scan a number. Return the number or nil if the current input isn't a valid number."

	| number digits fraction isFloat succeeded |
	digits := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' copyFrom: 1 to: anInteger.
	number := 0.
	succeeded := false.
	[digits includes: currentCharacter] whileTrue: 
			[number := number * anInteger + (digits indexOf: currentCharacter) - 1.
			self step.
			succeeded := true].
	succeeded ifFalse: [^nil].
	isFloat := false.
	(currentCharacter == $. and: [digits includes: stream peek]) 
		ifTrue: 
			[self step.
			isFloat := true.
			fraction := 1 / anInteger.
			[digits includes: currentCharacter] whileTrue: 
					[number := number + (((digits indexOf: currentCharacter) - 1) * fraction).
					fraction := fraction / anInteger.
					self step]].
	^isFloat ifTrue: [number asFloat] ifFalse: [number]
]

{ #category : #'private-scanning' }
RBOptimizedScanner >> scanNumberWithoutExponent [
	"Scan a number with the radix -- don't scan the exponent though"

	| number base |
	base := self scanNumberOfBase: 10.
	(currentCharacter == $r and: [base isInteger]) 
		ifTrue: 
			[| position |
			position := stream position.
			self step.
			number := self scanNumberOfBase: base.
			number isNil 
				ifTrue: 
					["Did not read a correct number, r must be start of a message send."

					stream position: position - 1.
					self step.
					number := base]]
		ifFalse: [number := base].
	^number
]
