"
I am a M3UA Application Server Process.

I have an internal state machine and a state and will be used by the
M3UA Layer. I am written for the usage in a Media Gateway Controller
and will also keep information about the Application Server itself.

If I need to be used on a Signalling Gateway (SG) I will need a dedicated
M3UA Application Server class and state machine.

I can currently only manage a single interface. The specification allows
a single ASP to send one ASPActive for one interface at a time.
"
Class {
	#name : #M3UAApplicationServerProcess,
	#superclass : #M3UAEntity,
	#instVars : [
		'applicationServer',
		'mtp3Boundary',
		't_ack',
		'asp_up_block',
		'asp_down_block',
		'asp_active_block',
		'asp_inactive_block',
		'established',
		'sctp_confirmed_block',
		'sctp_local_established_block',
		'sctp_released_block',
		'sctp_status_block',
		'asp_status_block',
		'rk_reg_block',
		'rk_dereg_block',
		'error_block',
		'sctp_restarted_block',
		'aspStateMachine',
		'name',
		'identifier',
		'networkService',
		'peersIdentifiers',
		'lastMsgReceived',
		'handledRoutingContexts'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
M3UAApplicationServerProcess class >> initWith: aService [
	^ self new
		networkService: aService;
		yourself
]

{ #category : #'instance creation' }
M3UAApplicationServerProcess class >> new [
	^ super new
		initialize;
		yourself
]

{ #category : #access }
M3UAApplicationServerProcess >> addRoutingContext: anInteger [
	handledRoutingContexts addLast: anInteger
]

{ #category : #accessing }
M3UAApplicationServerProcess >> applicationServer [
	^ applicationServer
]

{ #category : #accessing }
M3UAApplicationServerProcess >> applicationServer: anObject [
	applicationServer := anObject
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> aspActive [
	"M-ASP_ACTIVE request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP send an ASP Active message to its peer."

	^ self
		aspActiveWithTrafficModeType: self trafficModeType
		routingContexts: OrderedCollection new
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> aspActiveWithTrafficModeType: anIntegerTrafficMode routingContexts: aCollectionOfIntegerRC [
	"M-ASP_ACTIVE request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP send an ASP Active message to its peer."

	| msg |
	self
		logDebug: self class name , '/' , self name , ' aspActive.'
		area: #m3ua.
	self checkNextState: M3UAAspStateActive.
	self aspStateMachine aspAC: 'Link is active'.
	msg := M3UAASPActiveMessage newMessage
		addTag:
			(M3UATagINFOString new
				data: ('ASP is ACTIVE : ' , self name) asByteArray);
		yourself.
	anIntegerTrafficMode
		ifNotNil: [ msg
				addTag:
					(M3UATagASPTMAspActiveTrafficModeType
						initWithInteger32: anIntegerTrafficMode) ].
	aCollectionOfIntegerRC
		do:
			[ :anIntegerRC | msg addTag: (M3UATagRoutingContext initWithInteger32: anIntegerRC) ].

	"envoi du msg"
	msg originAspIdentifier: self identifier.
	self sendToPeer: msg
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> aspDown [
	"M-ASP_DOWN request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP stop its operation and send an ASP Down
   message to its peer."

	| msg |
	self
		logDebug: self class name, '/', self name, ' aspDown.'
		area: #m3ua.
	self checkNextState: M3UAAspStateDown.
	self aspStateMachine aspDN: 'Link is down'.
	msg := M3UAASPDownMessage newMessage
		addTag: (M3UATagINFOString new data: ('ASP is DOWN : ', self name) asByteArray);
		yourself.
		
	"envoi du msg"
	self sendToPeer: msg
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> aspInactive [
	"M-ASP_INACTIVE request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP send an ASP Inactive message to its peer."

	| msg |
	self
		logDebug: self class name , '/', self name, ' aspInactive.'
		area: #m3ua.
	self checkNextState: M3UAAspStateInactive.
	self aspStateMachine aspIA: 'Link is inactive'.
	msg := M3UAASPInactiveMessage newMessage
			addTag: (M3UATagINFOString new data: ('ASP is INACTIVE : ', self name) asByteArray);
		   "addTag: self createRoutingContextTag;"
		   yourself.
		
	"envoi du msg"
	self sendToPeer: msg
]

{ #category : #callbacks }
M3UAApplicationServerProcess >> aspIsActivated [
		self
		logDebug:
			self class name , ' (' , self name
				, ' has received an ACTIVE ACK msg from its peer'
		area: #m3ua.

]

{ #category : #callbacks }
M3UAApplicationServerProcess >> aspIsDown [
		self
		logDebug:
			self class name , ' (' , self name
				, ' has received a DOWN ACK msg from its peer'
		area: #m3ua.

]

{ #category : #callbacks }
M3UAApplicationServerProcess >> aspIsInactivated [
		self
		logDebug:
			self class name , ' (' , self name
				, ' has received an INACTIVE ACK msg from its peer'
		area: #m3ua.

]

{ #category : #callbacks }
M3UAApplicationServerProcess >> aspIsUp [
		self
		logDebug:
			self class name , ' (' , self name
				, ' has received an UP ACK msg from its peer'
		area: #m3ua.

]

{ #category : #accessing }
M3UAApplicationServerProcess >> aspStateMachine [
	^ aspStateMachine
]

{ #category : #accessing }
M3UAApplicationServerProcess >> aspStateMachine: anObject [
	aspStateMachine := anObject
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> aspStatus [
	"M-ASP_STATUS request
   Direction: LM -> M3UA
   Purpose: LM requests that M3UA report the status of a local or remote ASP."




]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> aspUp [
	"M-ASP_UP request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP start its operation and send an ASP Up
   message to its peer."

	| msg |
	self
		logDebug: self class name, '/', self name, ' aspUp.'
		area: #m3ua.
	self checkNextState: M3UAAspStateInactive.
	self aspStateMachine aspUP: 'Link is up'.
	msg := M3UAASPUpMessage newMessage
		addTag: (M3UATagASPIdentifier new data: self identifier);
		addTag: (M3UATagINFOString new data: ('ASP is UP : ', self name) asByteArray);
		yourself.
		
	"envoi du msg"
	self sendToPeer: msg
]

{ #category : #private }
M3UAApplicationServerProcess >> callNotification: aBlock [
	aBlock ifNotNil: [ aBlock value ]
]

{ #category : #private }
M3UAApplicationServerProcess >> checkNextState: nextStateClass [
	"Check if nextState and state are compatible and if not throw an exception."

	| state |
	(state := self aspStateMachine state) class = nextStateClass
		ifTrue: [ ^ self
				error: ('M3UA ASP already in state <1p>' expandMacrosWith: state) ].
	(state nextPossibleStates includes: nextStateClass)
		ifFalse: [ ^ self
				error:
					('M3UA ASP illegal state transition from <1p> to <2p>.'
						expandMacrosWith: state
						with: nextStateClass) ]
]

{ #category : #'Primitives-RK (creation)' }
M3UAApplicationServerProcess >> createDeregistrationRequestWith: aRoutingContext [
	| msg |
	msg := M3UARegistrationRequestMessage newMessage.
	msg addTag: (M3UATagRoutingContext initWithInteger32: aRoutingContext).
	^ msg
]

{ #category : #tags }
M3UAApplicationServerProcess >> createInfoTag [
	^ M3UATagINFOString new data: 'Hello from Smalltalk' asByteArray
]

{ #category : #'Primitives MTP3-User (creation)' }
M3UAApplicationServerProcess >> createMTPDAUDRequestPrimitiveWithRoutingContext: anIntegerRC ni: anIntegerNI affectedPc: aBitmapPC infoString: aString [
	"Creation of a DAUD message (Destination State Audit)"

	| msg routingContextTag |
	msg := M3UADestinationAvailableMessage newMessage.
	anIntegerNI
		ifNotNil: [ msg addTag: (M3UATagNetworkAppearance new data: anIntegerNI) ].
	anIntegerRC
		ifNotNil: [ routingContextTag := M3UATagRoutingContext
				initWithInteger32: anIntegerRC.
			msg addTag: routingContextTag ].
	msg addTag: (M3UATagAffectedPointCode initWithBitmap: aBitmapPC).
	aString
		ifNotNil: [ msg
				addTag: (M3UATagINFOString new data: aString asByteArray);
				yourself ].
	^ msg
]

{ #category : #'Primitives MTP3-User (creation)' }
M3UAApplicationServerProcess >> createMTPPauseRequestPrimitiveWithRoutingContext: anIntegerRC ni: anIntegerNI affectedPcs: aCollectionOfBitmap infoString: aString [
	"Creation of a DUNA message (Destination Unavailable)"

	| msg routingContextTag |
	msg := M3UADestinationUnavailableMessage newMessage.
	anIntegerNI
		ifNotNil: [ msg addTag: (M3UATagNetworkAppearance new data: anIntegerNI) ].
	anIntegerRC
		ifNotNil: [ routingContextTag := M3UATagRoutingContext
				initWithInteger32: anIntegerRC.
			msg addTag: routingContextTag ].
	aCollectionOfBitmap
		do:
			[ :aBitmapPC | msg addTag: (M3UATagAffectedPointCode initWithBitmap: aBitmapPC) ].
	aString
		ifNotNil: [ msg
				addTag: (M3UATagINFOString new data: aString asByteArray);
				yourself ].
	^ msg
]

{ #category : #'Primitives MTP3-User (creation)' }
M3UAApplicationServerProcess >> createMTPResumeRequestPrimitiveWithRoutingContext: anIntegerRC ni: anIntegerNI affectedPcs: aCollectionOfBitmap infoString: aString [
	"Creation of a DAVA message (Destination Available)"

	| msg routingContextTag |
	msg := M3UADestinationAvailableMessage newMessage.
	anIntegerNI
		ifNotNil: [ msg addTag: (M3UATagNetworkAppearance new data: anIntegerNI) ].
	anIntegerRC
		ifNotNil: [ routingContextTag := M3UATagRoutingContext
				initWithInteger32: anIntegerRC.
			msg addTag: routingContextTag ].
	aCollectionOfBitmap
		do:
			[ :aBitmapPC | msg addTag: (M3UATagAffectedPointCode initWithBitmap: aBitmapPC) ].
	aString
		ifNotNil: [ msg
				addTag: (M3UATagINFOString new data: aString asByteArray);
				yourself ].
	^ msg
]

{ #category : #'Primitives MTP3-User (creation)' }
M3UAApplicationServerProcess >> createMTPStatusDUPURequestPrimitiveWithRoutingContext: anIntegerRC ni: anIntegerNI affectedPc: aBitmapPC userCause: anIntegerUserCause infoString: aString [
	"Creation of a DUPU message (Destination User Part Unavailable)"

	| msg routingContextTag |
	msg := M3UADestinationUserPartUnavailableMessage newMessage.
	anIntegerNI
		ifNotNil: [ msg addTag: (M3UATagNetworkAppearance new data: anIntegerNI) ].
	anIntegerRC
		ifNotNil: [ routingContextTag := M3UATagRoutingContext
				initWithInteger32: anIntegerRC.
			msg addTag: routingContextTag ].
	msg addTag: (M3UATagAffectedPointCode initWithBitmap: aBitmapPC).
	msg addTag: (M3UATagUserCause new data: anIntegerUserCause).
	aString
		ifNotNil: [ msg
				addTag: (M3UATagINFOString new data: aString asByteArray);
				yourself ].
	^ msg
]

{ #category : #'Primitives MTP3-User (creation)' }
M3UAApplicationServerProcess >> createMTPStatusSCONRequestPrimitiveWithRoutingContext: anIntegerRC ni: anIntegerNI affectedPcs: aCollectionOfBitmap concernedDestination: anIntegerDestination congestionIndications: anIntegerCongestion infoString: aString [
	"Creation of a SCON message (Signalling Congestion)"

	| msg routingContextTag |
	msg := M3UASignallingCongestionMessage newMessage.
	anIntegerNI
		ifNotNil: [ msg addTag: (M3UATagNetworkAppearance new data: anIntegerNI) ].
	anIntegerRC
		ifNotNil: [ routingContextTag := M3UATagRoutingContext
				initWithInteger32: anIntegerRC.
			msg addTag: routingContextTag ].
	aCollectionOfBitmap
		do:
			[ :aBitmapPC | msg addTag: (M3UATagAffectedPointCode initWithBitmap: aBitmapPC) ].
	msg
		addTag: (M3UATagConcernedDestination new data: anIntegerDestination).
	msg
		addTag: (M3UATagCongestionIndications new data: anIntegerCongestion).
	aString
		ifNotNil: [ msg
				addTag: (M3UATagINFOString new data: aString asByteArray);
				yourself ].
	^ msg
]

{ #category : #'Primitives MTP3-User (creation)' }
M3UAApplicationServerProcess >> createMTPTransferRequestPrimitiveWithData: aByteArray routingContext: anInteger opc: anIntegerOPC dpc: anIntegerDPC si: anIntegerSI ni: anIntegerNI mp: anIntegerMP sls: anIntegerSLS [
	| msg routingContextTag protocolDataTag |
	msg := M3UAPayloadDataMessage newMessage.
	anInteger
		ifNotNil: [ routingContextTag := M3UATagRoutingContext
				initWithInteger32: anInteger.
			msg addTag: routingContextTag ].
	protocolDataTag := M3UATagProtocolData
		userData: aByteArray
		opc: anIntegerOPC
		dpc: anIntegerDPC
		si: anIntegerSI
		ni: anIntegerNI
		mp: anIntegerMP
		sls: anIntegerSLS.
	msg addTag: protocolDataTag.
	^ msg
]

{ #category : #'Primitives-RK (creation)' }
M3UAApplicationServerProcess >> createRegistrationRequestWith: aCollectionOfRoutingKey [
	| msg |
	msg := M3UARegistrationRequestMessage newMessage.
	aCollectionOfRoutingKey
		do: [ :aRoutingKey | self addRoutingKey: aRoutingKey toRKMMessage: msg ].
	^ msg
]

{ #category : #access }
M3UAApplicationServerProcess >> dispatchData: aByteArray originAspIdentifier: anIdentifier [
	| msg |
	msg := M3UAMSG parseToClassFromStream: aByteArray.
	msg originAspIdentifier: anIdentifier.
	msg dispatchOnAsp: self.
	
	"for debug/tests"
	self halt.
	lastMsgReceived := msg

]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> handleAspActiveAck: aMsg [
	"M-ASP_ACTIVE confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received an ASP Active
   Ack message from its peer."

	t_ack ifNotNil: [t_ack cancel].
	self moveToState: M3UAAspStateActive.
	self callNotification: asp_active_block
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> handleAspDownAck: aMsg [
	"M-ASP_DOWN confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received an ASP Down Ack message
   from its peer."

	t_ack ifNotNil: [t_ack cancel].
	self moveToState: M3UAAspStateDown.
	self callNotification: asp_down_block
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> handleAspInactiveAck: aMsg [
	"M-ASP_INACTIVE confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received an ASP Inactive
   Ack message from its peer."

	t_ack ifNotNil: [t_ack cancel].
	self moveToState: M3UAAspStateInactive.
	self callNotification: asp_inactive_block
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> handleAspUpAck: aMsg [
	"M-ASP_UP confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received an ASP UP Ack message from
   its peer."

	t_ack ifNotNil: [t_ack cancel].
	self moveToState: M3UAAspStateInactive.
	self callNotification: asp_up_block
]

{ #category : #handling }
M3UAApplicationServerProcess >> handleError: aMsg [
	"Cancel pending operations.. because something went wrong"

	t_ack cancel.
	error_block ifNotNil: [ error_block value: aMsg ]
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> handleNotify: aMsg [
	t_ack ifNotNil: [ t_ack cancel ].
	self
		logDebug: self class name, '/', self name, ' has received a NOTIFY msg.'
		area: #m3ua.

]

{ #category : #handling }
M3UAApplicationServerProcess >> handleUnknownMessage: aMsg [
	"We got something we don't know. ignore it for now."

	
]

{ #category : #accessing }
M3UAApplicationServerProcess >> handledRoutingContexts [
	^ handledRoutingContexts
]

{ #category : #accessing }
M3UAApplicationServerProcess >> identifier [
	^ identifier
]

{ #category : #accessing }
M3UAApplicationServerProcess >> identifier: anObject [
	identifier := anObject
]

{ #category : #initialization }
M3UAApplicationServerProcess >> initialize [
	super initialize.
	mtp3Boundary := M3UAMTPLevel3Boundary on: self.
	aspStateMachine := M3UAAspStateMachine onAsp: self.
	peersIdentifiers := OrderedCollection new.
	handledRoutingContexts := OrderedCollection new
]

{ #category : #accessing }
M3UAApplicationServerProcess >> lastMsgReceived [
	^ lastMsgReceived
]

{ #category : #accessing }
M3UAApplicationServerProcess >> lastMsgReceived: aMsg [
	lastMsgReceived := aMsg
]

{ #category : #private }
M3UAApplicationServerProcess >> moveToState: newStateClass [
	| state |
	(((state := self aspStateMachine state) nextPossibleStates
		includes: newStateClass) or: [ state class = newStateClass ])
		ifFalse: [ ^ self
				error:
					('M3UA ASP Illegal state transition from <1p> to <2p>'
						expandMacrosWith: state
						with: newStateClass) ].

	"Change the state"
	self aspStateMachine moveToState: newStateClass
]

{ #category : #accessing }
M3UAApplicationServerProcess >> mtp3Boundary [
	^ mtp3Boundary
]

{ #category : #accessing }
M3UAApplicationServerProcess >> name [
	^ name
]

{ #category : #accessing }
M3UAApplicationServerProcess >> name: anObject [
	name := anObject
]

{ #category : #access }
M3UAApplicationServerProcess >> networkService [
	^ networkService
]

{ #category : #access }
M3UAApplicationServerProcess >> networkService: aService [
	networkService := aService.
	networkService
		onSctpConnect: [ self sctpConnected ];
		onSctpRelease: [ self sctpReleased ]
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> onAspActive: aBlock [
	"Callback that will be used when we will receive an #handleAspActiveAck: message.
	
	M-ASP_ACTIVE confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received an ASP Active
   Ack message from its peer."

	asp_active_block := aBlock
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> onAspDown: aBlock [
	"Callback that will be used when we will receive an #handleAspDownAck: message.
	
	M-ASP_DOWN confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received an ASP Down Ack message
   from its peer."

	asp_down_block := aBlock
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> onAspInactive: aBlock [
	"Callback that will be used when we will receive an #handleAspInactiveAck: message.
	
	M-ASP_INACTIVE confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received an ASP Inactive
   Ack message from its peer."

	asp_inactive_block := aBlock
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> onAspStatus: aBlock [
	"Callback.
	
	M-ASP_STATUS confirm
   Direction: M3UA -> LM
   Purpose: M3UA reports the status of local or remote ASP."

	asp_status_block := aBlock
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAApplicationServerProcess >> onAspUp: aBlock [
	"Callback that will be used when we will receive an #handleAspUpAck: message.
	
	M-ASP_UP confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received an ASP UP Ack message from
   its peer."

	asp_up_block := aBlock
]

{ #category : #'Primitives-LayerManagement-RK' }
M3UAApplicationServerProcess >> onRkDereg: aBlock [
	"M-RK_DEREG request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP deregister RK(s) with its peer by
   sending a DEREG REQ message."

	rk_dereg_block := aBlock

]

{ #category : #'Primitives-LayerManagement-RK' }
M3UAApplicationServerProcess >> onRkReg: aBlock [
	"M-RK_REG confirm
   Direction: M3UA -> LM
   Purpose: ASP reports that it has received REG RSP message with a
   registration status of successful from its peer."

	rk_reg_block := aBlock

]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> onSctpEstablished: aBlock [
	"Callback.
	
	M-SCTP_ESTABLISH confirm
   Direction: M3UA -> LM
   Purpose: ASP confirms to LM that it has established an SCTP
   association with its peer."

	sctp_confirmed_block := aBlock
]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> onSctpLocalEstablished: aBlock [
	"Callback to call when the ASP has established a SCTP association with its SGP (AS)"

	sctp_local_established_block := aBlock
]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> onSctpReleased: aBlock [
	"Callback.
	
	M-SCTP_RELEASE confirm
   Direction: M3UA -> LM
   Purpose: ASP confirms to LM that it has released SCTP association
   with its peer."

	sctp_released_block := aBlock
]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> onSctpRestarted: aBlock [
	"Callback.
	
	M-SCTP_RESTART indication
   Direction: M3UA -> LM
   Purpose: M3UA informs LM that an SCTP restart indication has been received."

	sctp_restarted_block := aBlock
]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> onSctpStatus: aBlock [
	"Callback.
	
	M-SCTP_STATUS confirm
   Direction: M3UA -> LM
   Purpose: M3UA responds with the status of an SCTP association."

	sctp_status_block := aBlock
]

{ #category : #accessing }
M3UAApplicationServerProcess >> peersIdentifiers [
	^ peersIdentifiers
]

{ #category : #access }
M3UAApplicationServerProcess >> sctpConnected [
	"The SCTP connection has been established"

	| wasEstablished |
	self
		logDebug: self class name , ' : ' , self name , ' / #sctpConnected'
		area: #m3ua.
	wasEstablished := established.
	established := true.
	aspStateMachine moveToState: M3UAAspStateDown.
	t_ack ifNotNil: [t_ack cancel].
	wasEstablished = true 
	    ifTrue: [sctp_local_established_block ifNotNil: [sctp_local_established_block value]]
	    ifFalse: [sctp_restarted_block ifNotNil: [sctp_restarted_block value]]
]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> sctpEstablish [
	"M-SCTP_ESTABLISH request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP establish an SCTP association with its
   peer."

	self
		logDebug: self class name , ' : ' , self name , ' / #sctpEstablish'
		area: #m3ua.
	established := false.
	networkService stop.
	networkService start
]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> sctpRelease [
	"M-SCTP_RELEASE request
   Direction: LM -> M3UA
   Purpose: LM requests that ASP release an SCTP association with its peer."

	established := false.
	networkService stop.
	t_ack ifNotNil: [ t_ack cancel ]
]

{ #category : #access }
M3UAApplicationServerProcess >> sctpReleased [
	"The SCTP connection has been released."

	self moveToState: M3UAAspStateDown.
	established = true ifFalse: [ ^ self ].
	sctp_released_block ifNotNil: [ sctp_released_block value ]
]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> sctpRestart [
]

{ #category : #'Primitives-LayerManagement-SCTP' }
M3UAApplicationServerProcess >> sctpStatus [
	"M-SCTP_STATUS request
   Direction: LM -> M3UA
   Purpose: LM requests that M3UA report the status of an SCTP association."
]

{ #category : #sending }
M3UAApplicationServerProcess >> sendToPeer: aMsg [
	t_ack ifNotNil: [ t_ack cancel ].
	t_ack := TimerScheduler instance
		scheduleInSeconds: 2
		block: [ "Re-send the message"
			self
				logNotice:
					('<1p>:<2p> Sending message has timed out'
						expandMacrosWith: networkService hostname
						with: networkService port)
				area: #m3ua.
			self sendToPeer: aMsg ].
	networkService sendToPeer: aMsg from: self
]

{ #category : #access }
M3UAApplicationServerProcess >> state [ 	
	^aspStateMachine state 
]

{ #category : #access }
M3UAApplicationServerProcess >> trafficModeType [
	^ applicationServer trafficModeTypeForASP: self
]
