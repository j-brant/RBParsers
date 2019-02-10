Class {
	#name : #RBEvaluator,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'receiver',
		'codeClass',
		'contextStack',
		'returnBlock'
	],
	#category : #'RB_Parse_Tree_Evaluator'
}

{ #category : #'instance creation' }
RBEvaluator class >> evaluate: aNode [
	^ self evaluate: aNode for: nil inClass: nil class
]

{ #category : #'instance creation' }
RBEvaluator class >> evaluate: aNode for: receiver [
	^ self evaluate: aNode for: receiver inClass: receiver class
]

{ #category : #'instance creation' }
RBEvaluator class >> evaluate: aNode for: receiver inClass: codeClass [
	^ self
		evaluate: aNode
		for: receiver
		inClass: codeClass
		context: Dictionary new
		block: [ :each | ^ each ]
]

{ #category : #'instance creation' }
RBEvaluator class >> evaluate: aNode for: receiver inClass: codeClass context: context block: returnBlock [
	^ self new
		receiver: receiver;
		codeClass: codeClass;
		addContext: context;
		returnBlock: returnBlock;
		visitNode: aNode
]

{ #category : #'instance creation' }
RBEvaluator class >> evaluateMethod: aNode for: receiver [
	^ self evaluateMethod: aNode for: receiver inClass: receiver class
]

{ #category : #'instance creation' }
RBEvaluator class >> evaluateMethod: aNode for: receiver inClass: codeClass [
	^ self
		evaluateMethod: aNode
		for: receiver
		inClass: codeClass
		arguments: #()
]

{ #category : #'instance creation' }
RBEvaluator class >> evaluateMethod: aNode for: receiver inClass: codeClass arguments: aCollection [
	(self
		evaluate: aNode
		for: receiver
		inClass: codeClass
		context: Dictionary new
		block: [ :each | ^ each ]) valueWithArguments: aCollection.
	^ receiver
]

{ #category : #private }
RBEvaluator >> addContext: contextDictionary [
	self contextStack add: contextDictionary
]

{ #category : #private }
RBEvaluator >> assignGlobalOrPool: aString to: anObject [
	(self globalOrPoolBindingFor: aString) value: anObject.
	^ anObject
]

{ #category : #private }
RBEvaluator >> codeClass [
	^ codeClass isNil
		ifTrue: [ receiver class ]
		ifFalse: [ codeClass ]
]

{ #category : #'initialize/release' }
RBEvaluator >> codeClass: aClass [
	codeClass := aClass
]

{ #category : #private }
RBEvaluator >> context [
	^ contextStack last
]

{ #category : #private }
RBEvaluator >> contextStack [
	^ contextStack isNil
		ifTrue: [ contextStack := OrderedCollection new ]
		ifFalse: [ contextStack ]
]

{ #category : #private }
RBEvaluator >> executeStatementsFor: aSequenceNode [
	^ aSequenceNode statements
		inject: nil
		into: [ :last :each | self visitNode: each ]
]

{ #category : #private }
RBEvaluator >> globalOrPoolBindingFor: aString [
	| binding |
	binding := receiver class bindingOf: aString.
	binding isNil
		ifTrue: [ binding := Smalltalk bindingOf: aString asSymbol ].
	binding isNil
		ifTrue: [ self error: 'Variable ' , aString , ' not found' ].
	^ binding
]

{ #category : #private }
RBEvaluator >> performMessage: messageNode receiver: aValue [
	| arguments selector |
	arguments := (messageNode arguments
		collect: [ :each | self visitNode: each ]) asArray.
	selector := messageNode selector.
	^ (messageNode receiver isVariable
		and: [ messageNode receiver name = 'super' ])
		ifTrue:
			[ 
			self
				performSuperMessage: selector
				receiver: aValue
				withArguments: arguments ]
		ifFalse:
			[ aValue perform: messageNode selector withArguments: arguments ]
]

{ #category : #private }
RBEvaluator >> performSuperMessage: selector receiver: aValue withArguments: arguments [
	| superclass |
	superclass := self codeClass superclass.
	superclass isNil
		ifFalse:
			[ superclass := superclass whichClassIncludesSelector: selector ].
	superclass isNil
		ifTrue:
			[ 
			aValue
				doesNotUnderstand: (Message selector: selector arguments: arguments) ].
	^ (superclass compiledMethodAt: selector)
		valueWithReceiver: aValue
		arguments: arguments
]

{ #category : #'initialize/release' }
RBEvaluator >> receiver: anObject [
	receiver := anObject
]

{ #category : #'initialize/release' }
RBEvaluator >> returnBlock: aBlock [
	returnBlock := aBlock
]

{ #category : #private }
RBEvaluator >> valueOfGlobalOrPool: aString [
	^ (self globalOrPoolBindingFor: aString) value
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitAssignmentNode: anAssignmentNode [
	| name value binding |
	name := anAssignmentNode variable name.
	value := self visitNode: anAssignmentNode value.
	binding := self context associationAt: name ifAbsent: [ nil ].
	binding isNil
		ifTrue:
			[ 
			| index |
			index := receiver class allInstVarNames
				indexOf: name
				ifAbsent: [ nil ].
			^ index isNil
				ifTrue: [ self assignGlobalOrPool: name to: value ]
				ifFalse: [ receiver instVarAt: index put: value ] ]
		ifFalse: [ binding value: value ].
	^ value
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitBlockNode: aBlockNode [
	^ RBFakeEvaluationBlock
		evaluate: aBlockNode
		for: receiver
		inClass: codeClass
		context: (Dictionary newFrom: self context)
		block: returnBlock
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitCascadeNode: aCascadeNode [
	| messageReceiver messages |
	messages := aCascadeNode messages.
	messageReceiver := self visitNode: messages first receiver.
	^ messages
		inject: nil
		into:
			[ :last :each | self performMessage: each receiver: messageReceiver ]
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitLiteralArrayNode: aRBLiteralArrayNode [
	^ aRBLiteralArrayNode value
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitLiteralNode: aLiteralNode [
	^ aLiteralNode value
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitMessageNode: aMessageNode [
	^ self
		performMessage: aMessageNode
		receiver: (self visitNode: aMessageNode receiver)
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitMethodNode: aMethodNode [
	^ RBFakeEvaluationBlock
		evaluate: aMethodNode
		for: receiver
		inClass: codeClass
		context: (Dictionary withAll: self context associations)
		block: returnBlock
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitOptimizedNode: anOptimizedNode [
	^ self visitNode: anOptimizedNode body
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitReturnNode: aReturnNode [
	returnBlock value: (self visitNode: aReturnNode value)
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitSequenceNode: aSequenceNode [
	| currentContext |
	aSequenceNode temporaries isEmpty
		ifTrue: [ ^ self executeStatementsFor: aSequenceNode ].
	contextStack
		add:
			(currentContext := Dictionary newFrom: self context).
	aSequenceNode temporaries
		do:
			[ :each | 
			| name |
			name := each name.
			currentContext
				removeKey: name ifAbsent: [  ];
				at: name put: nil ].
	^ [ self executeStatementsFor: aSequenceNode ]
		ensure: [ contextStack removeLast ]
]

{ #category : #'visitor/double dispatching' }
RBEvaluator >> visitVariableNode: aVariableNode [
	| name |
	name := aVariableNode name.
	(#('self' 'super') includes: name)
		ifTrue: [ ^ receiver ].
	^ self context
		at: name
		ifAbsent:
			[ 
			| index |
			index := receiver class allInstVarNames
				indexOf: name
				ifAbsent: [ nil ].
			index isNil
				ifTrue: [ self valueOfGlobalOrPool: name ]
				ifFalse: [ receiver instVarAt: index ] ]
]
