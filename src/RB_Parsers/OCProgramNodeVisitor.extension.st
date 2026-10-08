Extension { #name : 'OCProgramNodeVisitor' }

{ #category : '*RB_Parsers' }
OCProgramNodeVisitor >> visitOptimizedNode: anOptimizedNode [
	self visitNode: anOptimizedNode body
]
