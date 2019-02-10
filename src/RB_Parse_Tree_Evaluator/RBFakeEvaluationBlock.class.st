Class {
	#name : #RBFakeEvaluationBlock,
	#superclass : #Object,
	#instVars : [
		'blockNode',
		'receiver',
		'codeClass',
		'context',
		'returnBlock'
	],
	#category : #'RB_Parse_Tree_Evaluator'
}

{ #category : #'instance creation' }
RBFakeEvaluationBlock class >> evaluate: aNode for: aValue inClass: aClass context: aDictionary block: aBlock [
	^ self new
		evaluate: aNode
		for: aValue
		inClass: aClass
		context: aDictionary
		block: aBlock
]

{ #category : #accessing }
RBFakeEvaluationBlock >> argumentCount [
	^ blockNode arguments size
]

{ #category : #evaluating }
RBFakeEvaluationBlock >> cull: anArg [
	^ self numArgs = 0
		ifTrue: [ self value ]
		ifFalse: [ self value: anArg ]
]

{ #category : #evaluating }
RBFakeEvaluationBlock >> cull: firstArg cull: secondArg [
	^ self numArgs < 2
		ifTrue: [ self cull: firstArg ]
		ifFalse: [ self value: firstArg value: secondArg ]
]

{ #category : #evaluating }
RBFakeEvaluationBlock >> cull: firstArg cull: secondArg cull: thirdArg [
	^ self numArgs < 3
		ifTrue: [ self cull: firstArg cull: secondArg ]
		ifFalse: [ self value: firstArg value: secondArg value: thirdArg ]
]

{ #category : #unwinding }
RBFakeEvaluationBlock >> ensure: aBlock [
	^ [ self value ]
		ensure: [ aBlock value ]
]

{ #category : #'initialize/release' }
RBFakeEvaluationBlock >> evaluate: aNode for: aValue inClass: aClass context: aDictionary block: aBlock [
	blockNode := aNode.
	receiver := aValue.
	codeClass := aClass.
	context := aDictionary.
	returnBlock := aBlock
]

{ #category : #scheduling }
RBFakeEvaluationBlock >> fork [
	^ [ self value ] fork
]

{ #category : #scheduling }
RBFakeEvaluationBlock >> forkAt: aPriority [
	^ [ self value ] forkAt: aPriority
]

{ #category : #unwinding }
RBFakeEvaluationBlock >> ifCurtailed: aBlock [
	^ [ self value ]
		ifCurtailed: [ aBlock value ]
]

{ #category : #scheduling }
RBFakeEvaluationBlock >> newProcess [
	^ [ self value ] newProcess
]

{ #category : #scheduling }
RBFakeEvaluationBlock >> newProcessWithArguments: anArray [
	^ [ self valueWithArguments: anArray ] newProcess
]

{ #category : #accessing }
RBFakeEvaluationBlock >> numArgs [
	^ blockNode arguments size
]

{ #category : #exceptions }
RBFakeEvaluationBlock >> on: anExceptionSelector do: handlerBlock [
	^ [ self value ]
		on: anExceptionSelector
		do: [ :signal | handlerBlock value: signal ]
]

{ #category : #'control flow' }
RBFakeEvaluationBlock >> repeat [
	^ [ self value ] repeat
]

{ #category : #evaluating }
RBFakeEvaluationBlock >> value [
	^ self valueWithArguments: #()
]

{ #category : #evaluating }
RBFakeEvaluationBlock >> value: anArg [
	^ self valueWithArguments: (Array with: anArg)
]

{ #category : #evaluating }
RBFakeEvaluationBlock >> value: anArg1 value: anArg2 [
	^ self valueWithArguments: (Array with: anArg1 with: anArg2)
]

{ #category : #evaluating }
RBFakeEvaluationBlock >> value: anArg1 value: anArg2 value: anArg3 [
	^ self
		valueWithArguments: (Array with: anArg1 with: anArg2 with: anArg3)
]

{ #category : #evaluating }
RBFakeEvaluationBlock >> valueWithArguments: argumentCollection [
	blockNode arguments
		with: argumentCollection
		do:
			[ :varNode :arg | 
			context
				removeKey: varNode name ifAbsent: [  ];
				at: varNode name put: arg ].
	^ RBEvaluator
		evaluate: blockNode body
		for: receiver
		inClass: codeClass
		context: context
		block: returnBlock
]

{ #category : #'control flow' }
RBFakeEvaluationBlock >> whileFalse [
	^ [ self value ] whileFalse
]

{ #category : #'control flow' }
RBFakeEvaluationBlock >> whileFalse: aBlock [
	^ [ self value ] whileFalse: [ aBlock value ]
]

{ #category : #'control flow' }
RBFakeEvaluationBlock >> whileTrue [
	^ [ self value ] whileTrue
]

{ #category : #'control flow' }
RBFakeEvaluationBlock >> whileTrue: aBlock [
	^ [ self value ] whileTrue: [ aBlock value ]
]
