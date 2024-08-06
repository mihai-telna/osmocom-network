Class {
	#name : #M3UAAsStateDown,
	#superclass : #M3UAAsState,
	#category : #'M3UA-States'
}

{ #category : #'state-changes' }
M3UAAsStateDown >> onDN2IA: anEvent [
	"DN2IA: One ASP moves from ASP-DOWN to ASP-INACTIVE state."

	self moveToState: M3UAAsStateInactive
]
