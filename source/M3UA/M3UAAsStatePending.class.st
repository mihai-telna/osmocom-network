Class {
	#name : #M3UAAsStatePending,
	#superclass : #M3UAAsState,
	#category : #'M3UA-States'
}

{ #category : #'state-changes' }
M3UAAsStatePending >> onPN2AC: anEvent [
	"PN2AC: One ASP moves to ASP-ACTIVE."

	self moveToState: M3UAAsStateActive
]

{ #category : #'state-changes' }
M3UAAsStatePending >> onPN2DN: anEvent [
	"PN2DN: T(r) expiry; all the ASPs are in ASP-DOWN state."

	self moveToState: M3UAAsStateDown
]

{ #category : #'state-changes' }
M3UAAsStatePending >> onPN2IA: anEvent [
	"T(r) expiry; an ASP is in ASP-INACTIVE state but no ASPs are
   in ASP-ACTIVE state."

	self moveToState: M3UAAsStateInactive
]
