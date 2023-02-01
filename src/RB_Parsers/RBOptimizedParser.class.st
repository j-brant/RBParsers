Class {
	#name : #RBOptimizedParser,
	#superclass : #RBExtendedParser,
	#category : #'RB_Parsers'
}

{ #category : #'private-classes' }
RBOptimizedParser >> optimizedNodeClass [
	^RBOptimizedNode
]

{ #category : #'private-parsing' }
RBOptimizedParser >> parseLiteralArrayObject [
	currentToken isOptimized ifTrue: [^self parseOptimizedExpression].
	^super parseLiteralArrayObject
]

{ #category : #'private-parsing' }
RBOptimizedParser >> parseOptimizedExpression [
	| position node |
	position := currentToken start.
	self step.
	node := self optimizedNodeClass
		left: position
		body: (self parseStatements: false)
		right: currentToken start.
	(currentToken isSpecial and: [currentToken value == $)]) ifFalse: [self parserError: ''')'' expected'].
	self step.
	^node
]

{ #category : #'private-parsing' }
RBOptimizedParser >> parsePrimitiveObject [
	currentToken isOptimized ifTrue: [^self parseOptimizedExpression].
	^super parsePrimitiveObject
]

{ #category : #'private-parsing' }
RBOptimizedParser >> patchLiteralArrayToken [
	(currentToken isIdentifier or: [currentToken isBinary or: [currentToken isKeyword]]) ifFalse: [^self parserError: 'Invalid token'].
	currentToken := RBLiteralToken
		value: currentToken value asSymbol
		start: currentToken start
		stop: currentToken stop
]
