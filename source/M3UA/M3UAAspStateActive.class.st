Class {
	#name : #M3UAAspStateActive,
	#superclass : #M3UAAspState,
	#category : #'M3UA-States'
}

{ #category : #'state-changes' }
M3UAAspStateActive class >> nextPossibleStates [
	^
	{M3UAAspStateInactive.
	M3UAAspStateDown}
]

{ #category : #'state-changes' }
M3UAAspStateActive >> onAspDN: anEvent [
	"RFC4666 paragraph 4.3.1 :
	ASP-DOWN: The remote M3UA peer at the ASP/IPSP is unavailable, and/or
   the related SCTP association is down.  Initially, all ASPs/IPSPs will
   be in this state.  An ASP/IPSP in this state SHOULD NOT be sent any
   M3UA messages, with the exception of Heartbeat, ASP Down Ack, and
   Error messages."

	self moveToState: M3UAAspStateDown
]

{ #category : #'state-changes' }
M3UAAspStateActive >> onAspIA: anEvent [
	"RFC4666 paragraph 4.3.1 :
	ASP-INACTIVE: The remote M3UA peer at the ASP/IPSP is available (and
   the related SCTP association is up), but application traffic is
   stopped.  In this state, the ASP/IPSP SHOULD NOT be sent any DATA or
   SSNM messages for the AS for which the ASP/IPSP is inactive."

	self moveToState: M3UAAspStateInactive
]

{ #category : #'state-changes' }
M3UAAspStateActive >> onOtherAspInAsOverrides: anEvent [
	self moveToState: M3UAAspStateInactive
]

{ #category : #'state-changes' }
M3UAAspStateActive >> onSctpCdi: anEvent [
	"RFC4666 paragraph 4.3.1 :
	SCTP CDI: The SCTP CDI denotes the local SCTP layer's Communication
   Down Indication to the Upper Layer Protocol (M3UA) on an SGP.  The
   local SCTP layer will send this indication when it detects the loss 
	of connectivity to the ASP's peer SCTP layer.  SCTP CDI is understood
   as either a SHUTDOWN_COMPLETE notification or a COMMUNICATION_LOST
   notification from the SCTP layer."

	self moveToState: M3UAAspStateDown
]

{ #category : #'state-changes' }
M3UAAspStateActive >> onSctpRi: anEvent [
	"RFC4666 paragraph 4.3.1 :
	SCTP RI: The local SCTP layer's Restart indication to the upper-layer
   protocol (M3UA) on an SG.  The local SCTP will send this indication
   when it detects a restart from the peer SCTP layer."
	
	self moveToState: M3UAAspStateDown
]
