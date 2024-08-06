"
I represent the M3UA to Layer Management Boundary
"
Class {
	#name : #M3UALayerManagement,
	#superclass : #M3UAEntity,
	#instVars : [
		'as_status_block',
		'managedProcess'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
M3UALayerManagement class >> on: anAsp [
	^ self new
		applicationServerProcess: anAsp;
		yourself
]

{ #category : #access }
M3UALayerManagement >> applicationServerProcess [
	^managedProcess
]

{ #category : #access }
M3UALayerManagement >> applicationServerProcess: anApplicationServerProcess [
	managedProcess := anApplicationServerProcess.
	managedProcess
		onSctpLocalEstablished: [ self sctpLocalEstablished ];
		onSctpRestarted: [ self sctpLocalEstablished ];
		onAspUp: [ managedProcess aspIsUp ];
		onAspDown: [ managedProcess aspIsDown ];
		onAspActive: [ managedProcess aspIsActivated ];
		onAspInactive: [ managedProcess aspIsInactivated ]
]

{ #category : #'Primitives-LayerManagement-AS' }
M3UALayerManagement >> asStatus [
	"M-AS_STATUS request
   	Direction: LM -> M3UA
   	Purpose: LM requests that M3UA report the status of an AS."

]

{ #category : #'ASP Querying (Audit) - SSNM' }
M3UALayerManagement >> createDAUDQueryWithRoutingContext: anIntegerRC ni: anIntegerNI affectedPc: aBitmapPC infoString: aString [
	"Creation of a DAUD message (Destination State Audit)
	ASP is querying SGP to be informed of potental congestion"

	| msg routingContextTag |
	msg := M3UADestinationStateAuditMessage newMessage.
	anIntegerNI
		ifNotNil: [ msg
				addTag: (M3UATagNetworkAppearance initWithInteger32: anIntegerNI) ].
	anIntegerRC
		ifNotNil: [ routingContextTag := M3UATagRoutingContext
				initWithInteger32: anIntegerRC.
			msg addTag: routingContextTag ].
	msg addTag: (M3UATagAffectedPointCode initWithBitmap: aBitmapPC).
	aString
		ifNotNil: [ msg
				addTag: (M3UATagINFOString initWithData: aString asByteArray);
				yourself ].
	^ msg
]

{ #category : #'SG Sending - SSNM' }
M3UALayerManagement >> createDSRTWithRoutingContext: anIntegerRC ni: anIntegerNI affectedPc: aBitmapPC infoString: aString [
	"Creation of a DSRT message (Destination Restricted)
	SGP is sending informations to ASP"

	| msg routingContextTag |
	msg := M3UADestinationRestrictedMessage newMessage.
	anIntegerNI
		ifNotNil: [ msg addTag: (M3UATagNetworkAppearance initWithInteger32: anIntegerNI) ].
	anIntegerRC
		ifNotNil: [ routingContextTag := M3UATagRoutingContext
				initWithData: (anIntegerRC asByteArrayOfSize: 4).
			msg addTag: routingContextTag ].
	msg addTag: (M3UATagAffectedPointCode initWithBitmap: aBitmapPC).
	aString
		ifNotNil: [ msg
				addTag: (M3UATagINFOString initWithData: aString asByteArray);
				yourself ].
	^ msg
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

{ #category : #'Primitives-LayerManagement-RK' }
M3UALayerManagement >> handleRkDeregIndication [
	"M-RK_DEREG indication
   Direction: M3UA -> LM
   Purpose: M3UA informs LM that it has successfully processed an
   incoming DEREG REQ from its peer."

]

{ #category : #'Primitives-LayerManagement-RK' }
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

{ #category : #managing }
M3UALayerManagement >> manage [
	"I begin to manage the process."

	managedProcess
		sctpRelease;
		sctpEstablish
]

{ #category : #'Primitives-LayerManagement-AS' }
M3UALayerManagement >> onAsStatus: aBlock [
	"M-AS_STATUS confirm
   	Direction: M3UA -> LM
   	Purpose: M3UA reports the status of an AS."

	as_status_block := aBlock
]

{ #category : #'Primitives-LayerManagement-RK' }
M3UALayerManagement >> rkDereg [
	"M-RK_DEREG request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP deregister RK(s) with its peer by
   sending a DEREG REQ message."


	self flag: #todo.
	managedProcess createDeregistrationRequestWith: 0 
]

{ #category : #'Primitives-LayerManagement-RK' }
M3UALayerManagement >> rkReg [
	"M-RK_REG request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP register RK(s) with its peer by sending
   an REG REQ message"

	self flag: #todo.
	managedProcess createRegistrationRequestWith: OrderedCollection new
]

{ #category : #managing }
M3UALayerManagement >> sctpLocalEstablished [
	"ASP has confirmed to us (LM) that it has established an SCTP association with an SGP (AS)."

	managedProcess state class = M3UAAspStateActive
		ifTrue: [ ^ self ].
		
	"There is only one way forward"
	managedProcess aspUp
]
