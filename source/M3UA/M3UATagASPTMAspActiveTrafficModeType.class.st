Class {
	#name : #M3UATagASPTMAspActiveTrafficModeType,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagASPTMAspActiveTrafficModeType class >> nrValue [
	^ M3UAConstants tagASPTMAspActiveTrafficMode
]

{ #category : #testing }
M3UATagASPTMAspActiveTrafficModeType >> isBroadcast [
	^ self data asInteger = 3
]

{ #category : #testing }
M3UATagASPTMAspActiveTrafficModeType >> isLoadshare [
	^ self data asInteger = 2
]

{ #category : #testing }
M3UATagASPTMAspActiveTrafficModeType >> isOverride [
	^ self data asInteger = 1
]
