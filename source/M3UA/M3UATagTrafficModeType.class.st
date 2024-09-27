Class {
	#name : #M3UATagTrafficModeType,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagTrafficModeType class >> nrValue [
	^ M3UAConstants tagTrafficModeType
]

{ #category : #testing }
M3UATagTrafficModeType >> isBroadcast [
	^ self data asInteger = 3
]

{ #category : #testing }
M3UATagTrafficModeType >> isLoadshare [
	^ self data asInteger = 2
]

{ #category : #testing }
M3UATagTrafficModeType >> isOverride [
	^ self data asInteger = 1
]
