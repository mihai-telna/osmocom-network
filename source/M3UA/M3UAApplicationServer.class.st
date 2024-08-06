Class {
	#name : #M3UAApplicationServer,
	#superclass : #M3UAEntity,
	#instVars : [
		'name',
		'asStateMachine',
		'registeredAsps',
		'currentAsp',
		'routingTable',
		'networkService',
		'dicoPeers',
		'pointCode',
		'dicoTrafficModeType'
	],
	#category : #'M3UA-Core'
}

{ #category : #configuration }
M3UAApplicationServer >> addRemotePeer: aRemoteAsp forAsp: oneOfMyAsp [
	"Add a remote ASP with who oneOfMyAsp wants to talk to, through a SCTP connection"
	
	^ dicoPeers at: oneOfMyAsp put: aRemoteAsp
]

{ #category : #dispatch }
M3UAApplicationServer >> addRoutingKey: aM3UARoutingKey routingContext: anInteger [
	| routingKeys |
	routingKeys := routingTable at: anInteger ifAbsentPut: [ OrderedCollection new ].
	routingKeys addLast: aM3UARoutingKey
]

{ #category : #accessing }
M3UAApplicationServer >> asStateMachine [
	^ asStateMachine
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> canRespondToAsp: anApplicationServerProcess [
	self flag: #todo.
	^ anApplicationServerProcess notNil
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> chooseCurrentAsp [
	| indexCurrent |
	(self trafficModeName = 'round-robin'
		or: [ self trafficModeName = 'Loadshare' ])
		ifTrue: [ indexCurrent := currentAsp
				ifNil: [ 0 ]
				ifNotNil: [ registeredAsps indexOf: currentAsp ].
			currentAsp := registeredAsps
				at:
					(indexCurrent = registeredAsps size
						ifTrue: [ 1 ]
						ifFalse: [ indexCurrent + 1 ]) ]
		ifFalse: [ self flag: #todo.
			currentAsp := registeredAsps first ].
	^ currentAsp
]

{ #category : #accessing }
M3UAApplicationServer >> currentAsp [
	^ currentAsp
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> defaultTrafficModeTypeForASP [
	"1 Override
    2 Loadshare
    3 Broadcast"

	"What for Round-Robin ?"

	^ 2
]

{ #category : #miscellaneous }
M3UAApplicationServer >> errorCodeFror: aString [
	| dico |
	
	"=> class var + method"
	self flag: #todo.
	
	dico := Dictionary new.
	dico at: 'Invalid Version' put: '01'.
	dico at: 'Not Used in M3UA' put: '02'.
	dico at: 'Unsupported Message Class' put: '03'.
	dico at: 'Unsupported Message Type' put: '04'.
	dico at: 'Unsupported Traffic Mode Type' put: '05'.
	dico at: 'Unexpected Message' put: '06'.
	dico at: 'Protocol Error' put: '07'.
	dico at: 'Not Used in M3UA' put: '08'.
	dico at: 'Invalid Stream Identifier' put: '09'.
	dico at: 'Not Used in M3UA' put: '0a'.
	dico at: 'Not Used in M3UA' put: '0b'.
	dico at: 'Not Used in M3UA' put: '0c'.
	dico at: 'Refused - Management Blocking' put: '0d'.
	dico at: 'ASP Identifier Required' put: '0e'.
	dico at: 'Invalid ASP Identifier' put: '0f'.
	dico at: 'Not Used in M3UA' put: '10'.
	dico at: 'Invalid Parameter Value' put: '11'.
	dico at: 'Parameter Field Error' put: '12'.
	dico at: 'Unexpected Parameter' put: '13'.
	dico at: 'Destination Status Unknown' put: '14'.
	dico at: 'Invalid Network Appearance' put: '15'.
	dico at: 'Missing Parameter' put: '16'.
	dico at: 'Not Used in M3UA' put: '17'.
	dico at: 'Not Used in M3UA' put: '18'.
	dico at: 'Invalid Routing Context' put: '19'.
	dico at: 'No Configured AS for ASP' put: '1a'.
	^ ByteArray
		readHexFrom: (dico at: aString ifAbsent: [ '18' ]) asInteger
]

{ #category : #'asp searching' }
M3UAApplicationServer >> findAspWithIdentifier: aByteArray [
	"We are looking for an ASP within our own registered ASPs"

	registeredAsps
		do: [ :asp | 
			asp identifier = aByteArray asArray
				ifTrue: [ ^ asp ] ]
]

{ #category : #'asp searching' }
M3UAApplicationServer >> findRemoteAspSenderOf: aMsg [
	"We have received a UP, DOWN, ACTIVE, or INACTIVE from a remote peer,
	and we are going to answer it"

	| tag identifierTag |
	tag := (aMsg findTag: M3UAConstants tagASPIdentifier).
	identifierTag := tag 
		ifNil: [ aMsg originAspIdentifier ]
		ifNotNil: [tag data].
	identifierTag ifNil: [ ^ nil ].
	^ self findRemoteAspWithIdentifier: identifierTag
]

{ #category : #'asp searching' }
M3UAApplicationServer >> findRemoteAspWithIdentifier: aByteArray [
	"We are looking for a remote ASP known in our routing table"

	dicoPeers
		keysAndValuesDo: [ :localAsp :remoteAsp | 
			remoteAsp identifier = aByteArray asArray
				ifTrue: [ ^ remoteAsp ] ].
	^ nil
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> handleAspActive: aMsg [
	| aspSender |
	self
		logDebug:
			self class name , ' (' , self name
				, ') : ACTIVE msg received, I will answer it '
		area: #m3ua.
	self
		logDebug: self class name , '/' , self name , ' handleAspActive:'
		area: #m3ua.
	(aspSender := self findRemoteAspSenderOf: aMsg) ifNil: [ ^ self ].
	aspSender moveToState: M3UAAspStateActive.
	self isServerGateway
		ifTrue: [ self updateRemoteAsp: aspSender withMessageActive: aMsg ].
	self sendAspActiveAckForMessage: aMsg toSender: aspSender
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> handleAspDown: aMsg [
	| aspSender |
	self
		logDebug:
			self class name , ' (' , self name
				, ') : DOWN msg received, I will answer it '
		area: #m3ua.
	(aspSender := self findRemoteAspSenderOf: aMsg) ifNil: [ ^ self ].
	aspSender moveToState: M3UAAspStateDown.
	self sendAspDownAckToSender: aspSender
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> handleAspInactive: aMsg [
	| aspSender |
	self
		logDebug:
			self class name , ' (' , self name
				, ') : INACTIVE msg received, I will answer it '
		area: #m3ua.
	(aspSender := self findRemoteAspSenderOf: aMsg) ifNil: [ ^ self ].
	aspSender moveToState: M3UAAspStateInactive.
	self sendAspInactiveAckToSender: aspSender
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> handleAspUp: aMsg [
	| aspSender |
	self
		logDebug:
			self class name , ' (' , self name
				, ') : UP msg received, I will answer it '
		area: #m3ua.
	aspSender := self findRemoteAspSenderOf: aMsg.
	(self canRespondToAsp: aspSender)
		ifTrue: [ aspSender moveToState: M3UAAspStateInactive.
			self sendAspUpAckToSender: aspSender.
			^ true ]
		ifFalse: [ self
				sendErrorMessageCode: (self errorCodeFror: 'Refused - Management Blocking')
				toSender: aspSender.
			^ false ]
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> handleDeregistrationRequest: aRegReqMsg [
	"We will create a DEREG RSP message (Deregistration Response)"

	| routingContextTag msg |
	routingContextTag := aRegReqMsg
		findTag: M3UAConstants tagRoutingContext.
	msg := M3UADeregistrationResponseMessage newMessage.
	msg addTag: routingContextTag.
	msg
		addTag:
			(M3UATagDeregistrationResult
				initWithData32bitsInteger:
					((self
						findDeregistrationStatusForRoutingKey: routingContextTag routingContext) )).
	^ msg
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> handleRegistrationRequest: aRegReqMsg [
	"We will create a REG RSP message (Registration Response)"

	| routingKeyTags msg |
	routingKeyTags := aRegReqMsg findAllTags: M3UAConstants tagRoutingKey.
	msg := M3UARegistrationResponseMessage newMessage.
	routingKeyTags
		do: [ :routingKeyTag | 
			| resultTag |
			resultTag := M3UATagRegistrationResult
				initWithLocalRKIdentifier: routingKeyTag localRKIdentifier
				registrationStatus: (self findRegistrationStatusFromRoutingKeyTag: routingKeyTag)
				routingContext: routingKeyTag routingContext.
			msg addTag: resultTag ].
	^ msg
]

{ #category : #initialization }
M3UAApplicationServer >> initialize [
	super initialize.
	asStateMachine := M3UAAsStateMachine new.
	asStateMachine aspStateMachines: OrderedCollection new.
	registeredAsps := OrderedCollection new.
	routingTable := Dictionary new.
	dicoPeers := Dictionary new.
	name := ''.
	dicoTrafficModeType := Dictionary new
]

{ #category : #testing }
M3UAApplicationServer >> isServerGateway [
	^ false
]

{ #category : #accessing }
M3UAApplicationServer >> name [
	^ name
]

{ #category : #accessing }
M3UAApplicationServer >> name: anObject [
	name := anObject
]

{ #category : #accessing }
M3UAApplicationServer >> networkService [
	^ networkService
]

{ #category : #configuration }
M3UAApplicationServer >> networkService: anObject [
	networkService := anObject.
	
	"To put in class RHCentralForM3UA after tests validation"
	self flag: #temporarly.
	networkService onUnitData: [:senderRoutingKey :destinationAspIdentifier :pid :msg |
		msg dispatchOnAsp: self chooseCurrentAsp ].
]

{ #category : #'messages creation' }
M3UAApplicationServer >> notifyMessageActiveASP: anApplicationServerProcess routingContext: anIntegerRC [
	^ self
		notifyMessageStatus: M3UATagMGMTNotifyStatus infoAsActive
		identifier: anApplicationServerProcess identifier
		routingContext: anIntegerRC
		string:
			'NOTIFY masg ! ASP ' , anApplicationServerProcess name , 'ACTIVE '
				,
					(anIntegerRC
						ifNil: [ '' ]
						ifNotNil: [ '(RC :' , anIntegerRC printString , ')' ])
]

{ #category : #'messages creation' }
M3UAApplicationServer >> notifyMessageInactiveASP: anApplicationServerProcess routingContext: anIntegerRC [
	^ self
		notifyMessageStatus: M3UATagMGMTNotifyStatus infoAsInactive
		identifier: anApplicationServerProcess identifier
		routingContext: anIntegerRC
		string:
			'NOTIFY masg ! ASP ' , anApplicationServerProcess name , 'INACTIVE '
				,
					(anIntegerRC
						ifNil: [ '' ]
						ifNotNil: [ '(RC :' , anIntegerRC printString , ')' ])
]

{ #category : #'messages creation' }
M3UAApplicationServer >> notifyMessageStatus: anIntegerStatus identifier: aByteArray routingContext: anIntegerRC string: aString [
	| msg |
	msg := M3UANotifyMessage newMessage.
	msg
		addTag:
			(M3UATagMGMTNotifyStatus
				type: M3UATagMGMTNotifyStatus statusApplicationServerStateChange
				info: anIntegerStatus).
	aByteArray
		ifNotNil: [ msg addTag: (M3UATagASPIdentifier new data: aByteArray) ].
	anIntegerRC
		ifNotNil: [ msg addTag: (M3UATagRoutingContext initWithInteger32: anIntegerRC) ].
	msg addTag: (M3UATagINFOString new data: aString asByteArray).
	^ msg
]

{ #category : #dispatch }
M3UAApplicationServer >> onData: aData [
	| msg tagInfoString string aspOriginatorName nextAsp |
	self flag: #toRemove.
	msg := M3UAMSG parseToClassFromStream: aData.
	(tagInfoString := msg findTag: M3UAConstants tagINFOString)
		ifNotNil: [ string := tagInfoString data asString.
			aspOriginatorName := string
				copyFrom: (string indexOf: $:) + 2
				to: string size ].

	nextAsp := self chooseCurrentAsp.
	nextAsp name = aspOriginatorName
		ifFalse: [ msg dispatchOnAsp: nextAsp ]
]

{ #category : #'asp searching' }
M3UAApplicationServer >> peerIdentifierForAsp: oneOfMyAsp [
	"Return the identifier of a remote ASP with who oneOfMyAsp wants to talk to, 
	through a SCTP connection"

	^ (dicoPeers at: oneOfMyAsp ifAbsent: [ ^ nil ]) identifier
]

{ #category : #initialization }
M3UAApplicationServer >> registerASP: aM3UAApplicationServerProcess [
	self
		registerASP: aM3UAApplicationServerProcess
		trafficModeType: self defaultTrafficModeTypeForASP
]

{ #category : #initialization }
M3UAApplicationServer >> registerASP: aM3UAApplicationServerProcess trafficModeType: anAIntegerASPTrafficModeType [
	registeredAsps addLast: aM3UAApplicationServerProcess.
	dicoTrafficModeType
		at: aM3UAApplicationServerProcess
		put: anAIntegerASPTrafficModeType.
	aM3UAApplicationServerProcess applicationServer: self.
	asStateMachine aspStateMachines
		addLast: aM3UAApplicationServerProcess aspStateMachine.
	asStateMachine
		handleAnnouncementFor: aM3UAApplicationServerProcess aspStateMachine
]

{ #category : #accessing }
M3UAApplicationServer >> registeredAsps [
	^ registeredAsps
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> sendAspActiveAckForMessage: aMsgActive toSender: anApplicationServerProcess [
	| ack tagTrafficMode tagRoutingContext |
	tagTrafficMode := aMsgActive
		findTag: M3UAConstants tagASPTMAspActiveTrafficMode
		ifAbsent: [ nil ].
	tagRoutingContext := aMsgActive
		findTag: M3UAConstants tagRoutingContext
		ifAbsent: [ nil ].
		
	"ACH message"
	ack := M3UAASPActiveAckMessage newMessage.
	ack
		addTag:
			(tagTrafficMode
				ifNil: [ M3UATagASPTMAspActiveTrafficModeType new
						data: self defaultTrafficModeTypeForASP asByteArray ]).
	tagRoutingContext ifNotNil: [ ack addTag: tagRoutingContext ].
	ack
		addTag:
			(M3UATagINFOString new
				data:
					('ASP ACTIVE msg acked'
						,
							(tagRoutingContext
								ifNil: [ '' ]
								ifNotNil: [ ' (RC ' , tagRoutingContext data asInteger printString , ')' ]))
						asByteArray);
		yourself.
	networkService send: ack toRemoteAsp: anApplicationServerProcess
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> sendAspDownAckToSender: anApplicationServerProcess [
	| ack |
	ack := M3UAASPDownAckMessage newMessage
		addTag:
			(M3UATagINFOString new
				data: ('ASP DOWN msg acked') asByteArray);
		yourself.
	networkService send: ack toRemoteAsp: anApplicationServerProcess
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> sendAspInactiveAckToSender: anApplicationServerProcess [
	| ack |
	ack := M3UAASPInactiveAckMessage newMessage
		addTag:
			(M3UATagINFOString new
				data: ('ASP INACTIVE msg acked') asByteArray);
		yourself.
	networkService send: ack toRemoteAsp: anApplicationServerProcess
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> sendAspUpAckToSender: anApplicationServerProcess [
	| ack |
	ack := M3UAASPUpAckMessage newMessage
		addTag:
			(M3UATagINFOString new
				data: ('ASP UP msg acked') asByteArray);
		yourself.
	networkService send: ack toRemoteAsp: anApplicationServerProcess
]

{ #category : #'handling-messages-ASP' }
M3UAApplicationServer >> sendErrorMessageCode: anInteger toSender: anApplicationServerProcess [
	| ack |
	ack := M3UAErrorMessage newMessage
		addTag: (M3UAErrorMessage new data: anInteger asByteArray);
		yourself.
		
	"Add a RoutingContext tag for ACTIVE answer (mandatory)"
	self flag: #todo.
	networkService send: ack toRemoteAsp: anApplicationServerProcess
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> trafficModeName [
	self trafficModeTypeForEachASP = 1
		ifTrue: [ ^ 'Override' ].
	self trafficModeTypeForEachASP = 2
		ifTrue: [ ^ 'Loadshare' ].
	self trafficModeTypeForEachASP = 1
		ifTrue: [ ^ 'Broadcast' ].

	"Round-Robin ?"
	^ 'round-robin'
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> trafficModeTypeForASP: anApplicationServerProcess [
	^ dicoTrafficModeType
		at: anApplicationServerProcess
		ifAbsent: [ self defaultTrafficModeTypeForASP ]
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> trafficModeTypeForEachASP [
	self flag: #todo.
	^ self defaultTrafficModeTypeForASP
]
