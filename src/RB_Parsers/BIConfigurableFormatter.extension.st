Extension { #name : #BIConfigurableFormatter }

{ #category : #'*RB_Parsers' }
BIConfigurableFormatter >> visitOptimizedNode: anOptimizedNode [
	codeStream nextPutAll: '##('.
	self visitNode: anOptimizedNode body.
	codeStream nextPut: $)
]
