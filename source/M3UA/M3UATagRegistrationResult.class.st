Class {
	#name : #M3UATagRegistrationResult,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #'instance creation' }
M3UATagRegistrationResult class >> initWithLocalRKIdentifier: anIntegerRKIdentifier registrationStatus: anIntegerStatus routingContext: anIntegerRC [
	^ self
		initWithThreeInteger32:
			(Array
				with: anIntegerRKIdentifier
				with: anIntegerStatus
				with: anIntegerRC)
]

{ #category : #access }
M3UATagRegistrationResult class >> nrValue [
	^ M3UAConstants tagRegistrationResult
]
