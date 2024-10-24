Class {
	#name : #M3UATagConcernedDestination,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagConcernedDestination class >> nrValue [
	^ M3UAConstants tagConcernedDestination
]

{ #category : #access }
M3UATagConcernedDestination >> concernedDestination [
	^ (data copyFrom: 2 to: 4) asInteger
]
