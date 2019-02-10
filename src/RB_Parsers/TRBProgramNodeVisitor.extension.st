Extension { #name : #TRBProgramNodeVisitor }

{ #category : #'*RB_Parsers' }
TRBProgramNodeVisitor >> visitOptimizedNode: anOptimizedNode [
	self visitNode: anOptimizedNode body
]
