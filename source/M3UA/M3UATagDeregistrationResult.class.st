Class {
	#name : #M3UATagDeregistrationResult,
	#superclass : #M3UATagWithSubTags,
	#category : #'M3UA-Tags'
}

{ #category : #'instance creation' }
M3UATagDeregistrationResult class >> initWithRoutingContextId: anIntegerRC deregistrationStatus: anIntegerStatus [
	| tag |
	tag := self new.
	tag addTag: (M3UATagRoutingContext initWithInteger32: anIntegerRC).
	tag
		addTag: (M3UATagDeregistrationStatus initWithInteger32: anIntegerStatus).
	^ tag
]

{ #category : #access }
M3UATagDeregistrationResult class >> nrValue [
	^ M3UAConstants tagDeregistrationResult
]
