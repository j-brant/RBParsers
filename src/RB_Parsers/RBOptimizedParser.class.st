Class {
	#name : #RBOptimizedParser,
	#superclass : #RBParser,
	#classInstVars : [
		'rewriteParserClass'
	],
	#category : #'RB_Parsers'
}

{ #category : #private }
RBOptimizedParser class >> buildRewriteParserClass [
	| scannerClass parserClass method |
	scannerClass := self createSubclassOf: self basicNew scannerClass from: RBPatternScanner.
	parserClass := self createSubclassOf: self from: RBPatternParser.
	method := parserClass compiledMethodAt: #scannerClass.
	1 to: method numLiterals do: [:i | (method literalAt: i) isVariableBinding ifTrue: [method literalAt: i put: (method literalAt: i) key -> scannerClass]].
	^parserClass
]

{ #category : #private }
RBOptimizedParser class >> createSubclassOf: originalClass from: prototypeClass [
	| newClass newMethod |
	newClass := Behavior new.
	newClass
		superclass: originalClass;
		methodDictionary: MethodDictionary new;
		setFormat: originalClass format.
	prototypeClass
		selectorsAndMethodsDo: [:sel :method | 
			newMethod := method copy.
			1 to: newMethod numLiterals do: [:i | (newMethod literalAt: i) == prototypeClass ifTrue: [newMethod literalAt: i put: newClass]].
			newClass addSelector: sel withMethod: newMethod].
	newMethod := (RBOptimizedParser class compiledMethodAt: #dummyMethod) copy.
	1 to: newMethod numLiterals do: [:i | (newMethod literalAt: i) = #() ifTrue: [newMethod literalAt: i put: originalClass]].
	newClass addSelector: #class withMethod: newMethod.
	^newClass
]

{ #category : #private }
RBOptimizedParser class >> dummyMethod [
	^#()
]

{ #category : #accessing }
RBOptimizedParser class >> parseRewriteExpression: aString onError: aBlock [
	| node parser |
	parser := self rewriteParserClass new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString.
	node := parser parseExpression: aString.
	^(node statements size == 1 and: [node temporaries isEmpty]) ifTrue: [node statements first] ifFalse: [node]
]

{ #category : #accessing }
RBOptimizedParser class >> parseRewriteMethod: aString onError: aBlock [
	| parser |
	parser := self rewriteParserClass new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString.
	^parser parseMethod: aString
]

{ #category : #private }
RBOptimizedParser class >> rewriteParserClass [
	^rewriteParserClass ifNil: [rewriteParserClass := self buildRewriteParserClass]
]

{ #category : #accessing }
RBOptimizedParser >> initializeParserWith: aString [
	| str aStream |
	source := aString.
	aStream := ReadStream on: aString.
	str := self scannerClass basicNew on: aStream.
	str
		errorBlock: errorBlock;
		step;
		stripSeparators.
	self scanner: str
]

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
