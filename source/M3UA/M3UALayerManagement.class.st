"
I represent the M3UA to Layer Management Boundary
"
Class {
	#name : #M3UALayerManagement,
	#superclass : #M3UAEntity,
	#instVars : [
		'as_status_block',
		'logicalEntity'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
M3UALayerManagement class >> on: aM3UALogicalEntity [
	^ self new
		logicalEntity: aM3UALogicalEntity;
		yourself
]

{ #category : #'Primitives-LayerManagement-AS' }
M3UALayerManagement >> asStatus [
	"M-AS_STATUS request
   	Direction: LM -> M3UA
   	Purpose: LM requests that M3UA report the status of an AS."

]

{ #category : #managing }
M3UALayerManagement >> aspIsActivated: anApplicationServerProcess [
	self
		logDebug:
			self class name , ' (' , anApplicationServerProcess name , ')'
				, ' has received an ACTIVE ACK msg from its peer'
		area: #m3ua.
	self handleAspActiveIndication
]

{ #category : #managing }
M3UALayerManagement >> aspIsDown: anApplicationServerProcess [
	self
		logDebug:
			self class name , ' (' , anApplicationServerProcess name , ')'
				, ' has received an DOWN ACK msg from its peer'
		area: #m3ua.
	self handleAspDownIndication
]

{ #category : #managing }
M3UALayerManagement >> aspIsInactivated: anApplicationServerProcess [
	self
		logDebug:
			self class name , ' (' , anApplicationServerProcess name , ')'
				, ' has received an INACTIVE ACK msg from its peer'
		area: #m3ua.
	self handleAspInactiveIndication
]

{ #category : #managing }
M3UALayerManagement >> aspIsUp: anApplicationServerProcess [
	self
		logDebug:
			self class name , ' (' , anApplicationServerProcess name , ')'
				, ' has received an UP ACK msg from its peer'
		area: #m3ua.
	self handleAspUpIndication
]

{ #category : #'Primitives-LayerManagement-AS' }
M3UALayerManagement >> handleAsActiveIndication [
	"M-AS_ACTIVE indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that an AS has moved to the AS-ACTIVE state."

]

{ #category : #'Primitives-LayerManagement-AS' }
M3UALayerManagement >> handleAsDownIndication [
	"M-AS_DOWN indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that an AS has moved to the AS-DOWN state."

]

{ #category : #'Primitives-LayerManagement-AS' }
M3UALayerManagement >> handleAsInactiveIndication [
	"M-AS_INACTIVE indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that an AS has moved to the AS-INACTIVE state."

]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UALayerManagement >> handleAspActiveIndication [
	"M-ASP_ACTIVE indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that it has successfully processed an incoming
   ASP Active message from its peer."

]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UALayerManagement >> handleAspDownIndication [
	"M-ASP_DOWN indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that it has successfully processed an incoming
   ASP Down message from its peer, or the SCTP association has
   been lost/reset."

]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UALayerManagement >> handleAspInactiveIndication [
	"M-ASP_INACTIVE indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that it has successfully processed an incoming
   ASP Inactive message from its peer."

]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UALayerManagement >> handleAspUpIndication [
	"M-ASP_UP indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that it has successfully processed an incoming
   ASP Up message from its peer."

]

{ #category : #'Primitives-LayerManagement' }
M3UALayerManagement >> handleErrorIndication [
	" M-ERROR indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that it has received an Error message from
   its peer or that a local operation has been unsuccessful."
]

{ #category : #'Primitives-LayerManagement' }
M3UALayerManagement >> handleNotifyIndication [
	"M-NOTIFY indication
   Direction: M3UA -> LM
   Purpose: M3UA reports that it has received a Notify message
   from its peer."
]

{ #category : #'Primitives-LayerManagement-RKM' }
M3UALayerManagement >> handleRkDeregIndication [
	"M-RK_DEREG indication
   Direction: M3UA -> LM
   Purpose: M3UA informs LM that it has successfully processed an
   incoming DEREG REQ from its peer."

]

{ #category : #'Primitives-LayerManagement-RKM' }
M3UALayerManagement >> handleRkRegIndication [
	"M-RK_REG indication
   Direction: M3UA -> LM
   Purpose: M3UA informs LM that it has successfully processed an
   incoming REG REQ message."

]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UALayerManagement >> handleSctpEstablishedIndication [
	"M-SCTP_ESTABLISH indication
   Direction: M3UA -> LM
   Purpose: M3UA informs LM that a remote ASP has established an SCTP
   association."

]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UALayerManagement >> handleSctpReleasedIndication [
	"M-SCTP_RELEASE indication
   Direction: M3UA -> LM
   Purpose: M3UA informs LM that a remote ASP has released an SCTP
   Association or that the SCTP association has failed."

]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UALayerManagement >> handleSctpRestartedIndication [
	"M-SCTP_RESTART indication
   Direction: M3UA -> LM
   Purpose: M3UA informs LM that an SCTP restart indication has been
   received."

]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UALayerManagement >> handleSctpStatusIndication [
	"M-SCTP STATUS indication
   Direction: M3UA -> LM
   Purpose: M3UA reports the status of an SCTP association."

]

{ #category : #accessing }
M3UALayerManagement >> logicalEntity [
	^ logicalEntity
]

{ #category : #accessing }
M3UALayerManagement >> logicalEntity: anObject [
	logicalEntity := anObject
]

{ #category : #managing }
M3UALayerManagement >> manageASP: anApplicationServerProcess [
	anApplicationServerProcess
		onSctpLocalEstablished: [ self sctpLocalEstablished: anApplicationServerProcess ];
		onSctpRestarted: [ self sctpLocalEstablished: anApplicationServerProcess ];
		onAspUp: [ self aspIsUp: anApplicationServerProcess ];
		onAspDown: [ self aspIsDown: anApplicationServerProcess ];
		onAspActive: [ self aspIsActivated: anApplicationServerProcess];
		onAspInactive: [ self aspIsInactivated: anApplicationServerProcess]
]

{ #category : #'Primitives-LayerManagement-AS' }
M3UALayerManagement >> onAsStatus: aBlock [
	"M-AS_STATUS confirm
   	Direction: M3UA -> LM
   	Purpose: M3UA reports the status of an AS."

	as_status_block := aBlock
]

{ #category : #'Primitives-LayerManagement-RKM' }
M3UALayerManagement >> rkDereg: anApplicationServerProcess with: aCollectionOfRoutingContexts [
	"M-RK_DEREG request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP deregister RK(s) with its peer by
   sending a DEREG REQ message."

	| deregistrationRequestMsg |
	deregistrationRequestMsg := anApplicationServerProcess
		createDeregistrationRequestWith: aCollectionOfRoutingContexts.
	^ deregistrationRequestMsg
]

{ #category : #'Primitives-LayerManagement-RKM' }
M3UALayerManagement >> rkReg: anApplicationServerProcess with: aCollectionOfRoutingKey [
	"M-RK_REG request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP register RK(s) with its peer by sending
   an REG REQ message"

	| registrationRequestMsg |
	registrationRequestMsg := anApplicationServerProcess
		createRegistrationRequestWith: aCollectionOfRoutingKey.
	^ registrationRequestMsg
]

{ #category : #managing }
M3UALayerManagement >> sctpLocalEstablished: anApplicationServerProcess [
	"ASP has confirmed to us (LM) that it has established an SCTP association with an SGP (AS)."

	anApplicationServerProcess state class = M3UAAspStateActive
		ifTrue: [ ^ self ].
		
	"There is only one way forward"
	anApplicationServerProcess aspUp
]

{ #category : #managing }
M3UALayerManagement >> startASP: anApplicationServerProcess [
	"I begin to manage the process."

	anApplicationServerProcess
		sctpRelease;
		sctpEstablish
]
