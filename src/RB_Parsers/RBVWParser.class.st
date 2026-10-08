Class {
	#name : 'RBVWParser',
	#superclass : 'RBExtendedParser',
	#category : 'RB_Parsers',
	#package : 'RB_Parsers'
}

{ #category : 'parsing' }
RBVWParser class >> parseRewriteExpression: aString onError: aBlock [
	^ OCPatternParser parseExpression: aString onError: aBlock
]

{ #category : 'parsing' }
RBVWParser class >> parseRewriteMethod: aString onError: aBlock [
	^ OCPatternParser parseMethod: aString onError: aBlock
]

{ #category : 'accessing' }
RBVWParser >> initializeParserWith: aString [
	source := aString.
	self scanner: (self scannerClass on: (ReadStream on: aString))
]

{ #category : 'private - parsing' }
RBVWParser >> parseLiteralArrayObject [
	currentToken isSpecial
		ifTrue:
			[currentToken value = $( ifTrue: [^self parseLiteralArray].
			currentToken value == $[ ifTrue: [^self parseLiteralByteArray]].
	currentToken isLiteralArrayToken
		ifTrue:
			[^currentToken isForByteArray
				ifTrue: [self parseLiteralByteArray]
				ifFalse: [self parseLiteralArray]].

	currentToken isError ifTrue:[ |errorNode| errorNode :=  self parseErrorNode: currentToken cause.
		 ^ errorNode].

	"For the moment, special tokens are transformed into symbol."
	(currentToken isAssignment or: [ currentToken isSpecial ])
		ifTrue: [
			|node|
			node := self literalValueNodeClass
				value: currentToken value asSymbol
				start: currentToken start
				stop: currentToken stop.
			node addWarning: 'Use a proper symbol literal'.
			self step. "special"
			^node ].

	^self parsePrimitiveLiteral
]

{ #category : 'private - classes' }
RBVWParser >> scannerClass [
	^ RBVWScanner
]
