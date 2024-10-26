Class {
	#name : #M3UATagRegistrationResult,
	#superclass : #M3UATagWithSubTags,
	#category : #'M3UA-Tags'
}

{ #category : #'instance creation' }
M3UATagRegistrationResult class >> initWithLocalRKIdentifier: anIntegerRKIdentifier registrationStatus: anIntegerStatus routingContextId: anIntegerRC [
	| tag |
	tag := self new.
	tag
		addTag:
			(M3UATagLocalRoutingKeyIdentifier
				initWithInteger32: anIntegerRKIdentifier).
	tag
		addTag: (M3UATagRegistrationStatus initWithInteger32: anIntegerStatus).
	tag addTag: (M3UATagRoutingContext initWithInteger32: anIntegerRC).
	^ tag
]

{ #category : #access }
M3UATagRegistrationResult class >> nrValue [
	^ M3UAConstants tagRegistrationResult
]
