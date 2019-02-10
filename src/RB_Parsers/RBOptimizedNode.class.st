Class {
	#name : #RBOptimizedNode,
	#superclass : #RBValueNode,
	#instVars : [
		'left',
		'right',
		'body'
	],
	#category : #'RB_Parsers'
}

{ #category : #'instance creation' }
RBOptimizedNode class >> body: aSequenceNode [
	^(self new)
		body: aSequenceNode;
		yourself
]

{ #category : #'instance creation' }
RBOptimizedNode class >> left: leftInteger body: aSequenceNode right: rightInteger [
	^(self new)
		left: leftInteger
			body: aSequenceNode
			right: rightInteger;
		yourself
]

{ #category : #comparing }
RBOptimizedNode >> = anObject [
	^self == anObject or: [self class = anObject class and: [self body = anObject body]]
]

{ #category : #visitor }
RBOptimizedNode >> acceptVisitor: aProgramNodeVisitor [
	^aProgramNodeVisitor visitOptimizedNode: self
]

{ #category : #accessing }
RBOptimizedNode >> arguments [
	^#()
]

{ #category : #accessing }
RBOptimizedNode >> body [
	^body
]

{ #category : #accessing }
RBOptimizedNode >> body: stmtsNode [
	body := stmtsNode.
	body parent: self
]

{ #category : #accessing }
RBOptimizedNode >> children [
	^Array with: body
]

{ #category : #matching }
RBOptimizedNode >> copyInContext: aDictionary [
	^self class body: (body copyInContext: aDictionary)
]

{ #category : #comparing }
RBOptimizedNode >> equalTo: anObject withMapping: aDictionary [
	^self class = anObject class and: [self body equalTo: anObject body withMapping: aDictionary]
]

{ #category : #comparing }
RBOptimizedNode >> hash [
	^self body hash
]

{ #category : #testing }
RBOptimizedNode >> isFaulty [
	^ body isFaulty
]

{ #category : #testing }
RBOptimizedNode >> isImmediateNode [
	^true
]

{ #category : #'initialize-release' }
RBOptimizedNode >> left: leftInteger body: aSequenceNode right: rightInteger [
	left := leftInteger.
	self body: aSequenceNode.
	right := rightInteger
]

{ #category : #matching }
RBOptimizedNode >> match: aNode inContext: aDictionary [
	^aNode class == self class and: [body match: aNode body inContext: aDictionary]
]

{ #category : #testing }
RBOptimizedNode >> needsParenthesis [
	^false
]

{ #category : #accessing }
RBOptimizedNode >> precedence [
	^0
]

{ #category : #replacing }
RBOptimizedNode >> replaceNode: aNode withNode: anotherNode [
	body == aNode ifTrue: [self body: anotherNode]
]

{ #category : #accessing }
RBOptimizedNode >> startWithoutParentheses [
	^left
]

{ #category : #accessing }
RBOptimizedNode >> stopWithoutParentheses [
	^right
]
