Class {
	#name : #RBVWParser,
	#superclass : #RBExtendedParser,
	#category : #'RB_Parsers'
}

{ #category : #parsing }
RBVWParser class >> parseRewriteExpression: aString onError: aBlock [ 
	^RBPatternParser parseExpression: aString onError: aBlock
]

{ #category : #parsing }
RBVWParser class >> parseRewriteMethod: aString onError: aBlock [ 
	^RBPatternParser parseMethod: aString onError: aBlock
]

{ #category : #accessing }
RBVWParser >> initializeParserWith: aString [ 
	source := aString.
	self scanner: (self scannerClass on: (ReadStream on: aString) errorBlock: self errorBlock)
]

{ #category : #'private - parsing' }
RBVWParser >> parseLiteralArrayObject [
	currentToken isSpecial
		ifTrue: [ currentToken value = $( ifTrue: [ ^ self parseLiteralArray ].
			currentToken value == $[ ifTrue: [ ^ self parseLiteralByteArray ] ].
	currentToken isLiteralArrayToken
		ifTrue: [ ^ currentToken isForByteArray
				ifTrue: [ self parseLiteralByteArray ]
				ifFalse: [ self parseLiteralArray ] ].
	currentToken isError
		ifTrue: [ | errorNode |
			errorNode := self parserError: currentToken cause.
			^ errorNode ].
	currentToken isLiteralToken ifFalse: [ self patchLiteralArrayToken ].
	^ self parsePrimitiveLiteral
]

{ #category : #'private - classes' }
RBVWParser >> scannerClass [
	^ RBVWScanner
]
