Class {
	#name : #M3UATagDestinationPointCode,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagDestinationPointCode class >> nrValue [
	^ M3UAConstants tagDestinationPointCode
]

{ #category : #access }
M3UATagDestinationPointCode >> destinationPointCode [
	^ (data copyFrom: 2 to: 4) asInteger
]
