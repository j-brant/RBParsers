Class {
	#name : 'RBOptimizedParser',
	#superclass : 'RBExtendedParser',
	#category : 'RB_Parsers',
	#package : 'RB_Parsers'
}

{ #category : 'private-classes' }
RBOptimizedParser >> optimizedNodeClass [
	^ RBOptimizedNode
]

{ #category : 'private-parsing' }
RBOptimizedParser >> parseLiteralArrayObject [
	currentToken isOptimized ifTrue: [ ^ self parseOptimizedExpression ].
	^ super parseLiteralArrayObject
]

{ #category : 'private-parsing' }
RBOptimizedParser >> parseOptimizedExpression [
	| position node |
	position := currentToken start.
	self step.
	node := self optimizedNodeClass
			left: position
			body: OCSequenceNode new
			right: currentToken start.
	self
		parseStatements: false
		into: node body
		untilAnyCloserOf: ')'.
	(currentToken isSpecial: $))
		ifFalse: [ self addParserError: ''')'' expected' to: node body.
			^ node ].
	self step.
	^ node
]

{ #category : 'private-parsing' }
RBOptimizedParser >> parsePrimitiveObject [
	currentToken isOptimized ifTrue: [ ^ self parseOptimizedExpression ].
	^ super parsePrimitiveObject
]

{ #category : 'private-parsing' }
RBOptimizedParser >> patchLiteralArrayToken [
	(currentToken isIdentifier
		or: [ currentToken isBinary or: [ currentToken isKeyword ] ])
		ifFalse: [ ^ self parseErrorNode: 'Invalid token' ].
	currentToken := RBLiteralToken
			value: currentToken value asSymbol
			start: currentToken start
			stop: currentToken stop
]
