Class {
	#name : #RBExtendedParser,
	#superclass : #RBParser,
	#classInstVars : [
		'rewriteParserClass'
	],
	#category : #'RB_Parsers'
}

{ #category : #private }
RBExtendedParser class >> buildRewriteParserClass [
	| scannerClass parserClass method |
	scannerClass := self createSubclassOf: self basicNew scannerClass from: RBPatternScanner.
	parserClass := self createSubclassOf: self from: RBPatternParser.
	method := parserClass compiledMethodAt: #scannerClass.
	1 to: method numLiterals do: [:i | (method literalAt: i) isVariableBinding ifTrue: [method literalAt: i put: (method literalAt: i) key -> scannerClass]].
	^parserClass
]

{ #category : #private }
RBExtendedParser class >> createSubclassOf: originalClass from: prototypeClass [
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
RBExtendedParser class >> dummyMethod [
	^#()
]

{ #category : #accessing }
RBExtendedParser class >> parseRewriteExpression: aString onError: aBlock [
	| node parser |
	parser := self rewriteParserClass new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString.
	node := parser parseExpression: aString.
	^(node statements size == 1 and: [node temporaries isEmpty]) ifTrue: [node statements first] ifFalse: [node]
]

{ #category : #accessing }
RBExtendedParser class >> parseRewriteMethod: aString onError: aBlock [
	| parser |
	parser := self rewriteParserClass new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString.
	^parser parseMethod: aString
]

{ #category : #private }
RBExtendedParser class >> rewriteParserClass [
	^rewriteParserClass ifNil: [rewriteParserClass := self buildRewriteParserClass]
]

{ #category : #accessing }
RBExtendedParser >> initializeParserWith: aString [
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
