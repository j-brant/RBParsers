Class {
	#name : #RBQualifiedName,
	#superclass : #Object,
	#instVars : [
		'pathString'
	],
	#category : #'RB_Parsers'
}

{ #category : #'private - scanning' }
RBQualifiedName class >> pathString: aString [
	^ self new
		pathString: aString;
		yourself
]

{ #category : #accessing }
RBQualifiedName >> pathString [
	^ pathString
]

{ #category : #accessing }
RBQualifiedName >> pathString: anObject [
	pathString := anObject
]

{ #category : #accessing }
RBQualifiedName >> storeOn: aStream [
	aStream
		nextPutAll: '#{';
		nextPutAll: pathString trim;
		nextPut: $}
]
