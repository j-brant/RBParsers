Class {
	#name : #RBEvaluatorTestCase,
	#superclass : #TestCase,
	#classVars : [
		'ClassVariable'
	],
	#category : #'RB_Parse_Tree_Evaluator_Tests'
}

{ #category : #tests }
RBEvaluatorTestCase >> testArgumentCount [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'self should: [[] argumentCount = 0].
								self should: [[:a | ] argumentCount = 1].
								self should: [[:a :b :c :d :e | ] argumentCount = 5].
								true'.
	self assert: (RBEvaluator evaluate: parseTree for: self)
]

{ #category : #tests }
RBEvaluatorTestCase >> testBlocks [
	| parseTree |
	parseTree := RBParser parseExpression: '[:each | each * each]'.
	self
		assert:
			((1 to: 3) collect: (RBEvaluator evaluate: parseTree)) = #(1 4 9).
	parseTree := RBParser parseExpression: '[:a :b | a + b]'.
	self
		assert:
			((1 to: 3) inject: 0 into: (RBEvaluator evaluate: parseTree)) = 6.
	parseTree := RBParser
		parseExpression:
			'[:a :b :c | a + b + c] value: 1 value: 2 value: 3'.
	self assert: (RBEvaluator evaluate: parseTree) = 6
]

{ #category : #tests }
RBEvaluatorTestCase >> testCapturedContexts [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| blocks |
					blocks := OrderedCollection new.
					1 to: 10 do: [:i | blocks add: [i]].
					blocks inject: 0 into: [:sum :each | sum + each value]'.
	self assert: (RBEvaluator evaluate: parseTree for: 1) = 55
]

{ #category : #tests }
RBEvaluatorTestCase >> testCascadedMessage [
	| parseTree |
	parseTree := RBParser
		parseExpression: '1 * 2; printString; yourself; printString'.
	self assert: (RBEvaluator evaluate: parseTree) = '1'
]

{ #category : #tests }
RBEvaluatorTestCase >> testClassAccess [
	| parseTree |
	parseTree := RBParser parseExpression: 'String new'.
	self assert: (RBEvaluator evaluate: parseTree) = ''
]

{ #category : #tests }
RBEvaluatorTestCase >> testClassVariableAccess [
	| parseTree |
	ClassVariable := 2.
	parseTree := RBParser
		parseExpression: 'ClassVariable := ClassVariable * 2'.
	RBEvaluator evaluate: parseTree for: self.
	self assert: ClassVariable = 4
]

{ #category : #tests }
RBEvaluatorTestCase >> testDoesNotUnderstand [
	| parseTree |
	ClassVariable := 2.
	parseTree := RBParser parseExpression: '3 zork'.
	self
		should: [ RBEvaluator evaluate: parseTree for: self ]
		raise: MessageNotUnderstood
]

{ #category : #tests }
RBEvaluatorTestCase >> testEmptyBlock [
	| parseTree |
	parseTree := RBParser parseExpression: '[] value'.
	self assert: (RBEvaluator evaluate: parseTree for: 1) isNil
]

{ #category : #tests }
RBEvaluatorTestCase >> testEmptySequence [
	| parseTree |
	parseTree := RBParser parseExpression: ''.
	self assert: (RBEvaluator evaluate: parseTree for: 1) isNil
]

{ #category : #tests }
RBEvaluatorTestCase >> testEnsure [
	| parseTree |
	ClassVariable := false.
	parseTree := RBParser
		parseExpression: '[^self] ensure: [ClassVariable := true]'.
	RBEvaluator evaluate: parseTree for: self.
	self assert: ClassVariable
]

{ #category : #tests }
RBEvaluatorTestCase >> testExceptionHandling [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'[Notification raiseSignal + 4] on: Exception do: [:signal | signal resume: 4]'.
	self assert: (RBEvaluator evaluate: parseTree for: self) = 8
]

{ #category : #tests }
RBEvaluatorTestCase >> testFork [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| semaphore x |
			semaphore := Semaphore new.
			[x := 5.
			semaphore signal] fork.
			semaphore wait.
			x * x'.
	self assert: (RBEvaluator evaluate: parseTree for: self) = 25
]

{ #category : #tests }
RBEvaluatorTestCase >> testForkAt [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| semaphore x |
			semaphore := Semaphore new.
			[x := 5.
			semaphore signal] forkAt: Processor userBackgroundPriority.
			semaphore wait.
			x * x'.
	self assert: (RBEvaluator evaluate: parseTree for: self) = 25
]

{ #category : #tests }
RBEvaluatorTestCase >> testIfCurtailed [
	| parseTree |
	ClassVariable := false.
	parseTree := RBParser
		parseExpression: '[^self] ifCurtailed: [ClassVariable := true]'.
	RBEvaluator evaluate: parseTree for: self.
	self assert: ClassVariable
]

{ #category : #tests }
RBEvaluatorTestCase >> testIfCurtailedNot [
	| parseTree |
	ClassVariable := false.
	parseTree := RBParser
		parseExpression: '[self] ifCurtailed: [ClassVariable := true]'.
	RBEvaluator evaluate: parseTree for: self.
	self deny: ClassVariable
]

{ #category : #tests }
RBEvaluatorTestCase >> testInstanceVariableAccess [
	| parseTree |
	parseTree := RBParser
		parseExpression: 'stop to: start by: step negated'.
	self
		assert:
			(RBEvaluator evaluate: parseTree for: (1 to: 3)) = (3 to: 1 by: -1)
]

{ #category : #tests }
RBEvaluatorTestCase >> testInstanceVariableAssignment [
	| parseTree |
	parseTree := RBParser parseExpression: 'stop := 2. self'.
	self
		assert:
			(RBEvaluator evaluate: parseTree for: (1 to: 3)) = (1 to: 2)
]

{ #category : #tests }
RBEvaluatorTestCase >> testLiterals [
	| parseTree |
	parseTree := RBParser
		parseExpression: '#(1 2 3) collect: [:each | each * each]'.
	self assert: (RBEvaluator evaluate: parseTree) = #(1 4 9)
]

{ #category : #tests }
RBEvaluatorTestCase >> testNewProcess [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| semaphore x |
			semaphore := Semaphore new.
			[x := 5.
			semaphore signal] newProcess resume.
			semaphore wait.
			x * x'.
	self assert: (RBEvaluator evaluate: parseTree for: self) = 25
]

{ #category : #tests }
RBEvaluatorTestCase >> testNewProcessWithArguments [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| semaphore x |
			semaphore := Semaphore new.
			([:each | x := each.
			semaphore signal] newProcessWithArguments: #(5)) resume.
			semaphore wait.
			x * x'.
	self assert: (RBEvaluator evaluate: parseTree for: self) = 25
]

{ #category : #tests }
RBEvaluatorTestCase >> testNoReturnInMethod [
	| parseTree object |
	parseTree := RBParser
		parseMethod:
			'someMethod
					self printString'.
	object := Object new.
	self
		assert:
			(RBEvaluator evaluateMethod: parseTree for: object) = object
]

{ #category : #tests }
RBEvaluatorTestCase >> testNoVariableFound [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'
					self ifTrue: [| y | y := 2].
					y'.
	self
		should: [ RBEvaluator evaluate: parseTree for: true ]
		raise: Error
]

{ #category : #tests }
RBEvaluatorTestCase >> testPoolVariableAccess [
	| parseTree |
	parseTree := RBParser parseExpression: 'WindowSize'.
	self
		assert:
			(RBEvaluator evaluate: parseTree for: DeflateStream basicNew) = 32768
]

{ #category : #tests }
RBEvaluatorTestCase >> testRepeat [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| x |
			x := 1.
			[x := x + 1.
			x < 10 ifFalse: [^x]] repeat'.
	self assert: (RBEvaluator evaluate: parseTree) = 10
]

{ #category : #tests }
RBEvaluatorTestCase >> testReturnInBlockExpression [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'self do: [:each | each = 2 ifTrue: [^each]].
								self error: ''not found'''.
	self assert: (RBEvaluator evaluate: parseTree for: (1 to: 3)) = 2
]

{ #category : #tests }
RBEvaluatorTestCase >> testReturnInBlockMethod [
	| parseTree |
	parseTree := RBParser
		parseMethod:
			'findTwo
			self do: [:each | each = 2 ifTrue: [^each]].
			self error: ''not found'''.
	self
		assert:
			(RBEvaluator
				evaluateMethod: parseTree
				for: (1 to: 3)
				inClass: Interval
				arguments: #()) = 2
]

{ #category : #tests }
RBEvaluatorTestCase >> testSeparateTemporaries [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| captured |
				captured := [| x | x := 5. [x]] value.
				[|x | x := 6] value.
				captured value'.
	self assert: (RBEvaluator evaluate: parseTree for: 1) = 5
]

{ #category : #tests }
RBEvaluatorTestCase >> testSquared [
	| parseTree |
	parseTree := RBParser parseExpression: '| x | x := 12 * 12. ^x'.
	self assert: (RBEvaluator evaluate: parseTree) = 144
]

{ #category : #tests }
RBEvaluatorTestCase >> testSuperDoesNotUnderstand [
	| parseTree |
	ClassVariable := 2.
	parseTree := RBParser parseExpression: 'super * self'.
	self
		should:
			[ RBEvaluator evaluate: parseTree for: 2 inClass: Magnitude ]
		raise: MessageNotUnderstood
]

{ #category : #tests }
RBEvaluatorTestCase >> testSuperSends [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| stream |
			stream := WriteStream on: String new.
			super printOn: stream.
			stream contents'.
	self
		assert:
			(RBEvaluator evaluate: parseTree for: 1 inClass: Number)
				= 'a SmallInteger'
]

{ #category : #tests }
RBEvaluatorTestCase >> testWhileFalse [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| x |
			x := 1.
			[x >= 10] whileFalse: [x := x + 1].
			x'.
	self assert: (RBEvaluator evaluate: parseTree) = 10.
	parseTree := RBParser
		parseExpression:
			'| x |
			x := 1.
			[x := x + 1. x >= 10] whileFalse.
			x'.
	self assert: (RBEvaluator evaluate: parseTree) = 10
]

{ #category : #tests }
RBEvaluatorTestCase >> testWhileTrue [
	| parseTree |
	parseTree := RBParser
		parseExpression:
			'| x |
			x := 1.
			[x < 10] whileTrue: [x := x + 1].
			x'.
	self assert: (RBEvaluator evaluate: parseTree) = 10.
	parseTree := RBParser
		parseExpression:
			'| x |
			x := 1.
			[x := x + 1. x < 10] whileTrue.
			x'.
	self assert: (RBEvaluator evaluate: parseTree) = 10
]
