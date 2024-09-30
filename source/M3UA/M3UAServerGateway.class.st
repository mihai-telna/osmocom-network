"
Instance Variables
	dictRoutingContextActivities:		<Dictionary>
	remoteApplicationServers:		<OrderedCollection of (M3UAApplicationServer)>
	routingTable:		<Dictionary>

 - remoteApplicationServers : the ServerGateway is aware of all AS with who he can forward traffic.
  the ServerGateway has the knowledge of the state of each AS state machine.

- dictChannelsForRemoteAspsBySGP :
   <Dictionary> 
		key : <M3UAServerGatewayProcess>
		value: <Dictionary> 
			key: <Integer< (channel where the SGP communicates with remote ASP)
			value: <M3UAApplicationServerProcess> (remote ASP)
		
"
Class {
	#name : #M3UAServerGateway,
	#superclass : #M3UALogicalEntity,
	#instVars : [
		'routingTable',
		'remoteApplicationServers',
		'dictRoutingContextActivities',
		'dictChannelsForRemoteAspsBySGP'
	],
	#category : #'M3UA-Core'
}

{ #category : #'traffic mode' }
M3UAServerGateway >> chooseProcess [
	self flag: #todo.
	^ self registeredSgps first
]

{ #category : #'process searching' }
M3UAServerGateway >> chooseProcessForReplyingAnAckToMessage: aReceivedMessage [
	"By default, we choose the same ASP that has received the message"

	^ aReceivedMessage logicalProcessReceiver
]

{ #category : #'SG specific' }
M3UAServerGateway >> chooseRemoteASPForSendingToApplicationServer: aM3UAApplicationServer [
	^ aM3UAApplicationServer registeredAsps first
]

{ #category : #'SG specific' }
M3UAServerGateway >> chooseSGPForSending: aM3UAMessage [
	"SG specific implementation"

	^ self registeredSgps first
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> createNotifyMessageForInactivityStatusOfRemoteAsp: aRemoteAsp [
	| as notifyMsg |
	as := aRemoteAsp host.
	as asStateMachine statusInformation
		= M3UAAsStateMachine statusInfoAsInactive
		ifTrue: [ notifyMsg := M3UANotifyMessage newMessage.
			notifyMsg
				addTag:
					(M3UATagMGMTNotifyStatus
						type: M3UATagMGMTNotifyStatus statusApplicationServerStateChange
						info: M3UATagMGMTNotifyStatus infoAsInactive).
			aRemoteAsp identifier
				ifNotNil:
					[ :id | notifyMsg addTag: (M3UATagASPIdentifier new data: id asByteArray) ].
			aRemoteAsp host handledRoutingContexts
				do:
					[ :rc | notifyMsg addTag: (M3UATagRoutingContext initWithInteger32: rc) ].
			notifyMsg
				addTag:
					(M3UATagINFOString new
						data: ('NOTIFY : ASP ' , aRemoteAsp name , ' is INACTIVE') asByteArray).
			^ notifyMsg ]
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> createNotifyMessageForRemoteAsp: aRemoteAsp inAnswerOfMessage: aMsgActiveOrInactive activeOrInactive: aBoolean [
	| as notifyMsg tagsRoutingContext |
	as := aRemoteAsp host.
	notifyMsg := M3UANotifyMessage newMessage.

	"AS state has changed"
	as asStateMachine statusType
		= M3UAAsStateMachine statusTypeApplicationServerStateChange
		ifTrue: [ notifyMsg
				addTag:
					(M3UATagMGMTNotifyStatus
						type: M3UATagMGMTNotifyStatus statusApplicationServerStateChange
						info: as asStateMachine tagNotifyInformation).
			(tagsRoutingContext := aMsgActiveOrInactive
				findAllTags: M3UAConstants tagRoutingContext) isEmpty
				ifFalse: [ tagsRoutingContext do: [ :tagRc | notifyMsg addTag: tagRc ] ].
			notifyMsg
				addTag:
					(M3UATagINFOString new
						data:
							('NOTIFY : ASP ' , aRemoteAsp name , ' is '
								,
									(aBoolean
										ifTrue: [ 'ACTIVE' ]
										ifFalse: [ 'INACTIVE' ])) asByteArray).
			^ notifyMsg ].

	"AS state is with insufficient resources"
	as asStateMachine statusInformation
		= M3UAAsStateMachine statusInfoInsufficientResources
		ifTrue: [ notifyMsg
				addTag:
					(M3UATagMGMTNotifyStatus
						type: M3UATagMGMTNotifyStatus statusOther
						info: M3UATagMGMTNotifyStatus infoInsufficientASPResourcesActiveInAS).
			notifyMsg
				addTag:
					(M3UATagINFOString new
						data: ('NOTIFY : INSUFFICIENT RESOURCES IN AS ' , as name) asByteArray).
			^ notifyMsg ].
		
	^ nil
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> createNotifyMessageForRemoteAsp: aRemoteAsp inAnswerOfMessageActive: aMsgActive [
	| as notifyMsg statusInfo |
	as := aRemoteAsp host.
	 notifyMsg := M3UANotifyMessage newMessage.
	
	"AS state is ACTIVE"
	(statusInfo := as asStateMachine statusInformation)
		= M3UAAsStateMachine statusInfoAsActive
		ifTrue: [
			notifyMsg
				addTag:
					(M3UATagMGMTNotifyStatus
						type: M3UATagMGMTNotifyStatus statusApplicationServerStateChange
						info: M3UATagMGMTNotifyStatus infoAsActive).
			(aMsgActive findTag: M3UAConstants tagRoutingContext) ifNotNil: [ :tagRc | notifyMsg addTag: tagRc ].
			notifyMsg
				addTag:
					(M3UATagINFOString new
						data: ('NOTIFY : ASP ' , aRemoteAsp name , ' is ACTIVE') asByteArray).
			^ notifyMsg ].
		
	"AS state is still INACTIVE with insufficient resources"
	statusInfo = M3UAAsStateMachine statusInfoInsufficientResources 
		ifTrue: [ 
			notifyMsg
				addTag:
					(M3UATagMGMTNotifyStatus
						type: M3UATagMGMTNotifyStatus statusOther
						info: M3UATagMGMTNotifyStatus infoInsufficientASPResourcesActiveInAS).
			notifyMsg
				addTag:
					(M3UATagINFOString new
						data: ('NOTIFY : INSUFFICIENT RESOURCES IN AS ', as name) asByteArray).
			^ notifyMsg  ]
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> deregistrationResultForRoutingContext: aM3UAoutingContext [
	| dictionary wstream |
	dictionary := M3UADeregistrationRequestMessage
		dictionaryDeregistrationResult.
	^ (self
		isDeregistrationValidForRoutingContext: aM3UAoutingContext
		errorStream: (wstream := WriteStream on: (String new: 100)))
		ifTrue: [ dictionary at: 'Successfully Deregistered' ]
		ifFalse: [ dictionary at: wstream contents ]
]

{ #category : #accessing }
M3UAServerGateway >> dictRoutingContextActivities [
	^ dictRoutingContextActivities
]

{ #category : #accessing }
M3UAServerGateway >> dictRoutingContextActivities: anObject [
	dictRoutingContextActivities := anObject
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> extractRoutingKeyFromTag: aM3UATagRoutingKey [

	| routingKey tagLocalRoutingKeyIdentifier tagRoutingContext tagTrafficModeType tagNetworkAppearance tagServiceIndicators tagOriginatingPointCodeList array tagDestinationPointCode |
	routingKey := M3UARoutingKey new.
	
	"localRKIdentifier"
	tagLocalRoutingKeyIdentifier := aM3UATagRoutingKey findTag: M3UAConstants tagLocalRoutingKeyIdentifier.
	tagLocalRoutingKeyIdentifier ifNotNil: [:tag |  routingKey localRKIdentifier: tag data asInteger].
	
	"routingContext"
	tagRoutingContext := aM3UATagRoutingKey findTag: M3UAConstants tagRoutingContext.
	tagRoutingContext  ifNotNil: [:tag |  routingKey routingContext: tag data asInteger].

	"trafficModeType"
	tagTrafficModeType := aM3UATagRoutingKey findTag: M3UAConstants tagTrafficModeType.
	tagTrafficModeType  ifNotNil: [:tag |  routingKey trafficModeType: tag data asInteger].

	"networkAppearance"
	tagNetworkAppearance := aM3UATagRoutingKey findTag: M3UAConstants tagNetworkAppearance.
	tagNetworkAppearance  ifNotNil: [:tag |  routingKey networkAppearance: tag data asInteger].

	"serviceIndicators"
	tagServiceIndicators :=aM3UATagRoutingKey findTag: M3UAConstants tagServiceIndicators.
	tagServiceIndicators ifNotNil: [:tag |  routingKey serviceIndicators: (tag data asArray select: [:si | si isZero not])].

	"listOpc"
	tagOriginatingPointCodeList := aM3UATagRoutingKey findTag: M3UAConstants tagOriginatingPointCodeList.
	tagOriginatingPointCodeList ifNotNil: [:tag |  | pointCodes |
		pointCodes := OrderedCollection new.
		1 to: (array := tag data) size by: 4 do: [:start |
    		pointCodes addLast: (array copyFrom: start to: (start + 3 min: array size)) asInteger].
		routingKey listOpc: pointCodes].

	"dpc"
	tagDestinationPointCode := aM3UATagRoutingKey findTag: M3UAConstants tagDestinationPointCode.
	tagDestinationPointCode  ifNotNil: [:tag |  routingKey dpc: tag data asInteger].
	
	^ routingKey

]

{ #category : #'remote AS' }
M3UAServerGateway >> findRemoteAspWithIdentifier: aByteArray [
	remoteApplicationServers
		do: [ :as | 
			as registeredAsps
				do: [ :asp | 
					asp identifier = aByteArray asArray
						ifTrue: [ ^ asp ] ] ].
	^ nil
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleAspActive: aMsgActive receivedOnSGP: oneOfMySGP [
	| remoteAsp notifyMessage tagsRoutingContext unknownAspRCs rcs anOtherRemoteAsp as |
	"debug"
	self
		logDebug: ' : ACTIVE message received, I will answer it (#handleAspActive:)'.
	"end debug"
	self sendAspActiveAckForMessage: aMsgActive.

	"debug"
	self logDebug: ' : ACTIVE msg answered (handleAspActive:)'.
	"end debug"

	self
		handleMessage: aMsgActive
		activeOrInactive: true
		receivedOnSGP: oneOfMySGP
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleAspDown: aMsgDown [

	"debug"
	self logDebug: ' : DOWN message received, I will answer it (#handleAspDown:)'.
	"end debug"
	
	self sendAspDownAckForMessage: aMsgDown.
	
	"debug"
	self logDebug: ' : DOWN message answered (handleAspDown:)'.
	"end debug"

]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleAspHeartbeat: aMsgHeartbeat [

	"debug"
	self logDebug: ' : HEARTBEAT message received, I will answer it (#handleAspHeartbeat:)'.
	"end debug"
	
	self sendAspHeartbeatAckForMessage: aMsgHeartbeat
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleAspInactive: aMsgInactive receivedOnSGP: oneOfMySGP [

	"debug"
	self logDebug: ' : INACTIVE message received, I will answer it (handleAspInactive:)'.
	"end debug"
	
	self sendAspInactiveAckForMessage: aMsgInactive.

	"debug"
	self logDebug: ' : INACTIVE message answered (handleAspInactive:)'.
	"end debug"
	
	self
		handleMessage: aMsgInactive
		activeOrInactive: false
		receivedOnSGP: oneOfMySGP
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleAspUp: aMsgUp receivedOnSGP: oneOfMySGP [
	| tagIdentifier remoteAsp dict notifyMessage |
	
	"debug"
	self logDebug: ' : UP message received, I will answer it (handleAspUp:)'.
	"end debug"
	
	self sendAspUpAckForMessage: aMsgUp.

	"debug"
	self logDebug: ' : UP message answered (handleAspUp:)'.
	"end debug"
	
	"Is there an ASP identifier ?"
	tagIdentifier := aMsgUp
		findTag: M3UAConstants tagASPIdentifier
		ifAbsent: [ ^ self ].
		
	"debug"
	self logDebug: ' : tag identifier found (handleAspUp:) : ', tagIdentifier data asArray printString.
	"end debug"

	"Do we know this ASP ?"
	(remoteAsp := self findRemoteAspWithIdentifier: tagIdentifier data)
		ifNil: [^ self ].

	"debug"
	self logDebug: ' : remote ASP found (handleAspUp:) : ', remoteAsp name.
	"end debug"
		
	"store the link SGP-channel/remote asp"
	dict := dictChannelsForRemoteAspsBySGP at: oneOfMySGP ifAbsentPut: [ Dictionary new ].
	dict at: aMsgUp delegateChannel put: remoteAsp.
	
	"debug"
	self logDebug: ' : dict (handleAspUp:) : ', dict printString.
	"end debug"

	"update the AS state machine"
	remoteAsp moveToState: M3UAAspStateInactive.
	
	"put the RC of the remoteAsp to non operational (should be the case already)"
	remoteAsp host handledRoutingContexts
		do: [ :anIntegerRC | dictRoutingContextActivities at: anIntegerRC put: false ].
	
	"Create the notify message"
	notifyMessage := self createNotifyMessageForInactivityStatusOfRemoteAsp: remoteAsp.

	"debug"
	self logDebug: ' : notifyMessage (handleAspUp:) : ', notifyMessage class name.
	"end debug"
		
	"Send the notify message"
	oneOfMySGP networkService
		send: notifyMessage
		onChannel: aMsgUp delegateChannel
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> handleDeregistrationRequest: aDeregistrationRequestMsg receivedOnSgp: aSGP [
	"We will create a DEREG RSP message (Deregistration Response)"

	| routingContextTags aspSender routingContexts deregistrationStatus deregistrationResponseMsg notifyMessage |
	routingContextTags := aDeregistrationRequestMsg
		findAllTags: M3UAConstants tagRoutingContext.
	routingContexts := routingContextTags
		collect: [ :rcTag | rcTag data asInteger ].
	deregistrationStatus := OrderedCollection new.
	aspSender := self
		remoteAspMatchingChannel: aDeregistrationRequestMsg delegateChannel
		ofSGP: aSGP.
	routingContexts
		do: [ :rc | 
			| status |
			deregistrationStatus
				addLast: (status := self deregistrationResultForRoutingContext: rc).

			"if the deregistration is OK, we remove the RC"
			status isZero
				ifTrue: [ aspSender
						ifNotNil: [ aspSender host removeRoutingKeyWithRoutingContext: rc ] ] ].
				
	
	"create M3UADeregistrationResponseMessage"
	deregistrationResponseMsg := M3UADeregistrationResponseMessage
		newMessage.
	1 to: routingContexts size do: [ :i | 
		| resultTag rc deregStatus |
		rc := routingContexts at: i.
		deregStatus := deregistrationStatus at: i.
		resultTag := M3UATagDeregistrationResult
			initWithRoutingContext: rc
			deregistrationStatus: deregStatus.
		deregistrationResponseMsg addTag: resultTag ].

	"send M3UADeregistrationResponseMessage"
	aSGP networkService
		send: deregistrationResponseMsg
		onChannel: aDeregistrationRequestMsg delegateChannel.
	aspSender ifNil: [ ^ self ].

	"Create a notify message"
	notifyMessage := self createNotifyMessageForInactivityStatusOfRemoteAsp: aspSender.

	"debug"
	self
		logDebug:
			' : notifyMessage (handleDeregistrationRequest:) : '
				, notifyMessage class name.
	"end debug"

	"Send the notify message"
	aSGP networkService
		send: notifyMessage
		onChannel: aDeregistrationRequestMsg delegateChannel
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleMessage: aMsgActiveOrInactive activeOrInactive: aBoolean receivedOnSGP: oneOfMySGP [
	| remoteAsp notifyMessage tagsRoutingContext unknownAspRCs rcs anOtherRemoteAsp as strDebugActiveOrInactive errorMessage |
	strDebugActiveOrInactive := aBoolean
		ifTrue: [ '(handleAspActive:)' ]
		ifFalse: [ '(handleAspInactive:)' ].

	"Do we know this ASP ?"
	(remoteAsp := self
		remoteAspMatchingChannel: aMsgActiveOrInactive delegateChannel
		ofSGP: oneOfMySGP) ifNil: [ ^ self ].

	"debug"
	self
		logDebug:
			' : remote ASP found ' , strDebugActiveOrInactive , ' : '
				, remoteAsp name.
	"end debug"

	"update the AS state machine"
	aBoolean
		ifTrue: [ remoteAsp moveToState: M3UAAspStateActive ]
		ifFalse: [ remoteAsp moveToState: M3UAAspStateInactive ].

	"Is there some RC passed in arguments ? if no, all RCS will be operational/non-operational depending the message active/inactive"
	tagsRoutingContext := aMsgActiveOrInactive
		findAllTags: M3UAConstants tagRoutingContext.
	rcs := tagsRoutingContext
		collect:
			[ :aTagInMsgActiveOrInactive | aTagInMsgActiveOrInactive data asInteger ].
	rcs isEmpty
		ifTrue: [ rcs addAllLast: remoteAsp host handledRoutingContexts ].

	"update the RC(s) of the remoteAsp to operational/non-operational"
	unknownAspRCs := OrderedCollection new.
	rcs
		do: [ :rc | 
			(remoteAsp host handledRoutingContexts includes: rc)
				ifTrue: [ dictRoutingContextActivities at: rc put: aBoolean ]
				ifFalse: [ unknownAspRCs addLast: rc ] ].
			
	"Send an error message if routing context(s) is(are) unknown"
	unknownAspRCs isEmpty
		ifFalse: [ errorMessage := self
				createErrorMessageCode: M3UATagMGMTErrorCode invalidRoutingContextValue.
			unknownAspRCs
				do: [ :rc | 
					errorMessage
						addTag: (M3UATagRoutingContext initDataWithOne32bitsInteger: rc) ] ].

	"Create the notify message"
	notifyMessage := self
		createNotifyMessageForRemoteAsp: remoteAsp
		inAnswerOfMessage: aMsgActiveOrInactive
		activeOrInactive: aBoolean.

	"debug"
	self
		logDebug:
			' : notifyMessage ' , strDebugActiveOrInactive , ' : '
				, notifyMessage class name.
	"end debug"

	"Send the notify message.
	If the AS state is in Insufficient Resources, we have to send the notify message to an other ASP"
	(as := remoteAsp host) asStateMachine statusInformation
		= M3UAAsStateMachine statusInfoInsufficientResources
		ifTrue: [ anOtherRemoteAsp := as registeredAsps
				detect: [ :asp | 
					asp ~~ remoteAsp
						and: [ asp aspStateMachine state class = M3UAAspStateActive ] ]
				ifNone: [ self
						logDebug:
							'No other ASP has been found for informing of Insufficient Resource for AS '
								, as name.
					^ oneOfMySGP networkService
						send: notifyMessage
						onChannel: aMsgActiveOrInactive delegateChannel ].
			self
				logDebug:
					'Another ASP has been found for informing of Insufficient Resource for AS '
						, as name , ' : ' , anOtherRemoteAsp name.
			oneOfMySGP sendMessage: notifyMessage toPeer: anOtherRemoteAsp.
			^ self ].

	"usual case"
	oneOfMySGP networkService
		send: notifyMessage
		onChannel: aMsgActiveOrInactive delegateChannel
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> handleRegistrationRequest: aRegistrationRequestMsg receivedOnSgp: aSGP [
	"We will create a REG RSP message (Registration Response)"

	| routingKeyTags routingKeys registrationStatus registrationResponseMsg aspSender notifyMessage |
	routingKeyTags := aRegistrationRequestMsg
		findAllTags: M3UAConstants tagRoutingKey.
	routingKeys := OrderedCollection new.
	registrationStatus := OrderedCollection new.
	aspSender := self
		remoteAspMatchingChannel: aRegistrationRequestMsg delegateChannel
		ofSGP: aSGP.
	routingKeyTags
		do: [ :routingKeyTag | 
			| routingKey status |
			routingKey := self extractRoutingKeyFromTag: routingKeyTag.
			routingKeys addLast: routingKey.
			registrationStatus
				addLast: (status := self registrationResultForRoutingKey: routingKey).

			"if the routingKey is OK, we store it"
			status isZero
				ifTrue: [ aspSender
						ifNotNil: [ aspSender host
								addRoutingKey: routingKey
								forRoutingContext: routingKey routingContext ] ] ].

	"create M3UARegistrationResponseMessage"
	registrationResponseMsg := M3UARegistrationResponseMessage newMessage.
	1 to: routingKeys size do: [ :i | 
		| resultTag rk regStatus |
		rk := routingKeys at: i.
		regStatus := registrationStatus at: i.
		resultTag := M3UATagRegistrationResult
			initWithLocalRKIdentifier: rk localRKIdentifier
			registrationStatus: regStatus
			routingContext: rk routingContext.
		registrationResponseMsg addTag: resultTag ].

	"send M3UARegistrationResponseMessage"
	aSGP networkService
		send: registrationResponseMsg
		onChannel: aRegistrationRequestMsg delegateChannel.
	aspSender ifNil: [ ^ self ].

	"Create a notify message"
	notifyMessage := self createNotifyMessageForInactivityStatusOfRemoteAsp: aspSender.

	"debug"
	self
		logDebug:
			' : notifyMessage (handleRegistrationRequest:) : '
				, notifyMessage class name.
	"end debug"

	"Send the notify message"
	aSGP networkService
		send: notifyMessage
		onChannel: aRegistrationRequestMsg delegateChannel
]

{ #category : #initialization }
M3UAServerGateway >> initialize [
	super initialize.
	dictRoutingContextActivities := Dictionary new.
	routingTable := Dictionary new.
	remoteApplicationServers := OrderedCollection new.
	dictChannelsForRemoteAspsBySGP := Dictionary new
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> isDeregistrationValidForRoutingContext: aM3UAoutingKey errorStream: aStream [
	"Cases to test :
		- Error - Unknown
		- Error - Invalid Routing Context
		- Error - Permission Denied
		- Error - Not Registered
		- Error - ASP Currently Active for Routing Context"

	self flag: #todo.
	^ true
]

{ #category : #testing }
M3UAServerGateway >> isServerGateway [
	^ true
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> isValidRoutingKey: aM3UAoutingKey errorStream: aStream [
	"TCases to test :
		- Error - Unknown
		- Error - Invalid DPC
		- Error - Invalid Network Appearance'
		- Error - Invalid Routing Key
		- Error - Permission Denied
		- Error - Cannot Support Unique Routing
		- Error - Routing Key not Currently Provisioned
		- Error - Insufficient Resources
		- Error - Unsupported RK parameter Field
		- Error - Unsupported/Invalid Traffic Handling Mode
		- Error - Routing Key Change Refused
		- Error - Routing Key Already Registered"

	self flag: #todo.
	^ true
]

{ #category : #'remote AS' }
M3UAServerGateway >> registerRemoteApplicationServer: anM3UAApplicationServer [
	remoteApplicationServers addLast: anM3UAApplicationServer.

	"Copy the Routing Context and set them inactive"
	anM3UAApplicationServer handledRoutingContexts
		do: [ :rc | self dictRoutingContextActivities at: rc put: false ]
]

{ #category : #initialization }
M3UAServerGateway >> registerSGP: aM3UAServerGatewayProcess [
	aM3UAServerGatewayProcess host: self.

	"Add to the SGP list"
	self registeredSgps addLast: aM3UAServerGatewayProcess
]

{ #category : #access }
M3UAServerGateway >> registeredSgps [
	^ registeredProcesses
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> registrationResultForRoutingKey: aM3UAoutingKey [
	| dictionary wstream |
	dictionary := M3UARegistrationRequestMessage
		dictionaryRegistrationResult.
	^ (self
		isValidRoutingKey: aM3UAoutingKey
		errorStream: (wstream := WriteStream on: (String new: 100)))
		ifTrue: [ dictionary at: 'Successfully Registered' ]
		ifFalse: [ dictionary at: wstream contents ]
]

{ #category : #accessing }
M3UAServerGateway >> remoteApplicationServers [
	^ remoteApplicationServers
]

{ #category : #access }
M3UAServerGateway >> remoteAspMatchingChannel: anInteger ofSGP: oneOfMySGP [
	^ (dictChannelsForRemoteAspsBySGP at: oneOfMySGP)
		at: anInteger
		ifAbsent: [ nil ]
]

{ #category : #sending }
M3UAServerGateway >> replyToMessage: aMsg withACK: aMsgACK [
	| processForSendingTheAck |
	processForSendingTheAck := self
		chooseProcessForReplyingAnAckToMessage: aMsg.

	"debug"
	self
		logDebug:
			processForSendingTheAck class name , ' found for replying : '
				, processForSendingTheAck name.
	"end debug"
	
	processForSendingTheAck
		sendAckMessage: aMsgACK
		inReplyToMessage: aMsg
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> sendAspActiveAckForMessage: aMsgActive [
	| ack tagTrafficMode tagsRoutingContext |
	tagTrafficMode := aMsgActive
		findTag: M3UAConstants tagTrafficModeType
		ifAbsent: [ nil ].
	tagsRoutingContext := aMsgActive
		findAllTags: M3UAConstants tagRoutingContext.

	"ACK message creation"
	ack := M3UAASPActiveAckMessage newMessage.
	tagTrafficMode ifNotNil: [ ack addTag: tagTrafficMode ].
	tagsRoutingContext isEmpty
		ifFalse: [ tagsRoutingContext do: [ :tagRC | ack addTag: tagRC ] ].
	ack
		addTag:
			(M3UATagINFOString new data: 'ASP ACTIVE message ACKED' asByteArray);
		yourself.

	"Send the ACK"
	self replyToMessage: aMsgActive withACK: ack
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> sendAspDownAckForMessage: aMsgDown [
	| ack |
	
	"ACK message creation"
	ack := M3UAASPDownAckMessage newMessage
		addTag:
			(M3UATagINFOString new
				data: ('ASP DOWN message ACKED') asByteArray);
		yourself.
		
	"Send the ACK"	
	self replyToMessage: aMsgDown withACK: ack
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> sendAspHeartbeatAckForMessage: aMsgHeartbeat [
	| ack |
	
	"ACK message creation"
	ack := M3UAASPHeartbeatAckMessage newMessage
		addTag: (aMsgHeartbeat findTag: M3UAConstants tagHeartbeatData);
		yourself.

	"Send the ACK"
	self replyToMessage: aMsgHeartbeat withACK: ack
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> sendAspInactiveAckForMessage: aMsgInactive [
	| ack |
	
	"ACK message creation"
	ack := M3UAASPInactiveAckMessage newMessage
		addTag:
			(M3UATagINFOString new data: 'ASP INACTIVE message ACKED' asByteArray);
		yourself.

	"Send the ACK"
	self replyToMessage: aMsgInactive withACK: ack
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> sendAspUpAckForMessage: aMsgUp [
	| ack |
	
	"ACK message creation"
	ack := M3UAASPUpAckMessage newMessage
		addTag:
			(M3UATagINFOString new
				data: ('ASP UP message ACKED') asByteArray);
		yourself.
		
	"debug"
	self logDebug: ' : ACKUP msg created : ', ack class name.
	"end debug"
		
	"Send the ACK"	
	self replyToMessage: aMsgUp withACK: ack
]

{ #category : #sending }
M3UAServerGateway >> sendMessage: aM3UAMessage toApplicationServer: aM3UAApplicationServer [
	"Use this method for sending messages which don't expect a ACK in reply"

	| sgp |
	sgp := (self chooseSGPForSending: aM3UAMessage) ifNil: [ ^ self ].
	sgp networkService
		send: aM3UAMessage
		from: sgp
		toTargetPeer:
			(self
				chooseRemoteASPForSendingToApplicationServer: aM3UAApplicationServer)
]
