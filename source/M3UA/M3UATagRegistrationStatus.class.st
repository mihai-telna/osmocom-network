Class {
	#name : #M3UATagRegistrationStatus,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagRegistrationStatus class >> nrValue [
	^ M3UAConstants tagRegistrationStatus
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorCannotSupportUniqueRouting [
	^ self data asInteger = 6
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorInsufficientResources [
	^ self data asInteger = 8
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorInvalidDPC [
	^ self data asInteger = 2
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorInvalidNetworkAppearance [
	^ self data asInteger = 3
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorInvalidRoutingKey [
	^ self data asInteger = 4
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorPermissionDenied [
	^ self data asInteger = 5
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorRoutingKeyAlreadyRegistered [
	^ self data asInteger = 12
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorRoutingKeyChangeRefused [
	^ self data asInteger = 11
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorRoutingKeyNotCurrentlyProvisioned [
	^ self data asInteger = 7
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorUnknown [
	^ self data asInteger = 1
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorUnsupportedOrInvalidTrafficHandlingMode [
	^ self data asInteger = 10
]

{ #category : #testing }
M3UATagRegistrationStatus >> isErrorUnsupportedRKParameterField [
	^ self data asInteger = 9
]

{ #category : #testing }
M3UATagRegistrationStatus >> isSuccessfullyRegistered [
	^ self data asInteger = 0
]
