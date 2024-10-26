Class {
	#name : #M3UATagINFOString,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #'instance creation' }
M3UATagINFOString class >> fromString: aString [
	^ self new data: aString asByteArray
]

{ #category : #access }
M3UATagINFOString class >> nrValue [
	^ M3UAConstants tagINFOString
]
