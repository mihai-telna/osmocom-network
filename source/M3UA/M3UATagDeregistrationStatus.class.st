Class {
	#name : #M3UATagDeregistrationStatus,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagDeregistrationStatus class >> nrValue [
	^ M3UAConstants tagDeregistrationStatus
]

{ #category : #testing }
M3UATagDeregistrationStatus >> isASPCurrentlyActiveForRoutingContext [
	^ self data asInteger = 5
]

{ #category : #testing }
M3UATagDeregistrationStatus >> isErrorInvalidRoutingContext [
	^ self data asInteger = 2
]

{ #category : #testing }
M3UATagDeregistrationStatus >> isErrorNotRegistered [
	^ self data asInteger = 4
]

{ #category : #testing }
M3UATagDeregistrationStatus >> isErrorPermissionDenied [
	^ self data asInteger = 3
]

{ #category : #testing }
M3UATagDeregistrationStatus >> isErrorUnknown [
	^ self data asInteger = 1
]

{ #category : #testing }
M3UATagDeregistrationStatus >> isSuccessfullyDeregistered [
	^ self data asInteger = 0
]
