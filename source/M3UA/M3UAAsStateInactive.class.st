Class {
	#name : #M3UAAsStateInactive,
	#superclass : #M3UAAsState,
	#category : #'M3UA-States'
}

{ #category : #'state-changes' }
M3UAAsStateInactive >> onIA2AC: anEvent [
	"IA2AC: One ASP moves to ASP-ACTIVE, causing the number of ASPs in the
   ASP-ACTIVE state to be n.  In a special case of smooth start, this
   transition MAY be done when the first ASP moves to ASP-ACTIVE state."

	self moveToState: M3UAAsStateActive
]

{ #category : #'state-changes' }
M3UAAsStateInactive >> onIA2DN: anEvent [
	" IA2DN: The last ASP in ASP-INACTIVE moves to ASP-DOWN, causing all
   the ASPs to be in ASP-DOWN state."

	self moveToState: M3UAAsStateDown
]
