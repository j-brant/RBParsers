Class {
	#name : #BaselineOfRBParsers,
	#superclass : #BaselineOf,
	#category : #BaselineOfRBParsers
}

{ #category : #baselines }
BaselineOfRBParsers >> baseline: spec [
	<baseline>
	
	spec
		for: #common
		do:
			[ spec package: 'RB_Parsers'.
			spec package: 'RB_Parse_Tree_Evaluator'.
			spec package: 'RB_Parse_Tree_Evaluator_Tests' with: [ spec requires: 'RB_Parse_Tree_Evaluator' ] ]
]
