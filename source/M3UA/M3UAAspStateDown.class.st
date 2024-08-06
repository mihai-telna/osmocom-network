Class {
	#name : #M3UAAspStateDown,
	#superclass : #M3UAAspState,
	#category : #'M3UA-States'
}

{ #category : #'state-changes' }
M3UAAspStateDown class >> nextPossibleStates [
	^ {M3UAAspStateInactive}
]

{ #category : #'state-changes' }
M3UAAspStateDown >> onAspUP: anEvent [
	"RFC4666 paragraph 4.3.1, future state :
	ASP-INACTIVE: The remote M3UA peer at the ASP/IPSP is available (and
   the related SCTP association is up), but application traffic is
   stopped.  In this state, the ASP/IPSP SHOULD NOT be sent any DATA or
   SSNM messages for the AS for which the ASP/IPSP is inactive."

	self moveToState: M3UAAspStateInactive
]
