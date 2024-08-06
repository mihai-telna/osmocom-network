Class {
	#name : #M3UAAsStateActive,
	#superclass : #M3UAAsState,
	#category : #'M3UA-States'
}

{ #category : #'state-changes' }
M3UAAsStateActive >> onAC2PN: anEvent [
	"AC2PN: The last ASP in ASP-ACTIVE state moves to ASP-INACTIVE or
   ASP-DOWN states, causing the number of ASPs in ASP-ACTIVE to drop
   below 1."

	self moveToState: M3UAAsStatePending
]
