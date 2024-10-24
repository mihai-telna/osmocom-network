Class {
	#name : #M3UATagUserCause,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagUserCause class >> nrValue [
	^ M3UAConstants tagUserCause
]

{ #category : #testing }
M3UATagUserCause >> isMtp3UserIdentityAALType2Signalling [
	^ self mtp3UserIdentityField = 12
]

{ #category : #testing }
M3UATagUserCause >> isMtp3UserIdentityBearerIndependentCallControl [
	^ self mtp3UserIdentityField = 13
]

{ #category : #testing }
M3UATagUserCause >> isMtp3UserIdentityBroadbandISUP [
	^ self mtp3UserIdentityField = 9
]

{ #category : #testing }
M3UATagUserCause >> isMtp3UserIdentityGatewayControlProtocol [
	^ self mtp3UserIdentityField = 14
]

{ #category : #testing }
M3UATagUserCause >> isMtp3UserIdentityISUP [
	^ self mtp3UserIdentityField = 5
]

{ #category : #testing }
M3UATagUserCause >> isMtp3UserIdentitySCCP [
	^ self mtp3UserIdentityField = 3
]

{ #category : #testing }
M3UATagUserCause >> isMtp3UserIdentitySatelliteISUP [
	^ self mtp3UserIdentityField = 10
]

{ #category : #testing }
M3UATagUserCause >> isMtp3UserIdentityTUP [
	^ self mtp3UserIdentityField = 4
]

{ #category : #testing }
M3UATagUserCause >> isUnavailabilityInaccessibleRemoteUser [
	^ self unavailabilityCauseField = 2
]

{ #category : #testing }
M3UATagUserCause >> isUnavailabilityUnequippedRemoteUser [
	^ self unavailabilityCauseField = 1
]

{ #category : #testing }
M3UATagUserCause >> isUnavailabilityUnknown [
	^ self unavailabilityCauseField = 0
]

{ #category : #access }
M3UATagUserCause >> mtp3UserIdentityField [
	^ (self data copyFrom: 3 to: 4) asInteger
]

{ #category : #access }
M3UATagUserCause >> unavailabilityCauseField [
	^ (self data copyFrom: 1 to: 2) asInteger
]
