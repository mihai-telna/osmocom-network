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
		'remoteApplicationServers',
		'dictChannelsForRemoteAspsBySGP'
	],
	#category : #'M3UA-Core'
}

{ #category : #'traffic management' }
M3UAServerGateway >> activateRoutingContextId: anIntegerRC [
	trafficManagement dictRoutingContextActivities at: anIntegerRC put: true 
]

{ #category : #'traffic management' }
M3UAServerGateway >> activeOrDeactive: aBoolean routingContext: anIntegerRC [
	aBoolean
		ifTrue: [ self activateRoutingContextId: anIntegerRC ]
		ifFalse: [ self deactivateRoutingContextId: anIntegerRC ]
]

{ #category : #mockup }
M3UAServerGateway >> availableDestination: anIntegerDPC [
	"Simulate an unavaibility for a Destination Point Code"

	remoteApplicationServers
		do: [ :as | as trafficManagement availableDestination: anIntegerDPC ]
]

{ #category : #'traffic mode' }
M3UAServerGateway >> chooseProcess [
	self flag: #todo.
	^ self registeredSgps first
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

{ #category : #mockup }
M3UAServerGateway >> congestedDestination: anIntegerDPC [
	"Simulate a congestion for a Destination Point Code"

	remoteApplicationServers
		do: [ :as | as trafficManagement congestedDestination: anIntegerDPC ]
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createAndSendDAVAMessageForAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfRC infoString: aString toLogicalProcess: aLogicalProcess [
	| davaMessage |
	davaMessage := self
		createDAVAMessageForAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfRC
		infoString: aString.
	self chooseProcess sendMessage: davaMessage toPeer: aLogicalProcess
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createAndSendDUNAMessageForAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfRC infoString: aString toLogicalProcess: aLogicalProcess [
	| dunaMessage |
	dunaMessage := self
		createDUNAMessageForAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfRC
		infoString: aString.
	self chooseProcess sendMessage: dunaMessage toPeer: aLogicalProcess
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createAndSendDUPUMessageForAffectedPointCode: anIntegerApc mtp3User: anIntegerMTP3User networkAppearance: anIntegerNA routingContextsIds: aCollectionOfRC infoString: aString toLogicalProcess: aLogicalProcess [
	| dupuMessage |
	dupuMessage := self
		createDUPUMessageForAffectedPointCode: anIntegerApc
		mtp3User: anIntegerMTP3User
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfRC
		infoString: aString.
	self chooseProcess sendMessage: dupuMessage toPeer: aLogicalProcess
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createAndSendSCONMessageForAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfRC infoString: aString toLogicalProcess: aLogicalProcess [
	| sconMessage |
	sconMessage := self
		createSCONMessageForAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfRC
		infoString: aString.
	self chooseProcess sendMessage: sconMessage toPeer: aLogicalProcess
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createDAVAMessageForAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC infoString: aString [
	"Creation of a Destination Available Message"

	| davaMessage |
	davaMessage := M3UADestinationAvailableMessage newMessage.
	self
		fillSSNMMessage: davaMessage
		forAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
		infoString: aString.
	^ davaMessage
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createDRSTMessageForAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC infoString: aString [
	"Creation of a Destination Restricted Message"

	| drstMessage |
	drstMessage := M3UADestinationRestrictedMessage newMessage.
	self
		fillSSNMMessage: drstMessage
		forAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
		infoString: aString.
	^ drstMessage
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createDUNAMessageForAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC infoString: aString [
	"Creation of a Destination Unavailable Message"

	| dunaMessage |
	dunaMessage := M3UADestinationUnavailableMessage newMessage.
	self
		fillSSNMMessage: dunaMessage
		forAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
		infoString: aString.
	^ dunaMessage
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createDUPUMessageForAffectedPointCode: anIntegerDPC mtp3User: anIntegerMTP3User networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC infoString: aString [
	"Creation of a Destination User Part Unavailable Message"

	| dupuMessage |
	dupuMessage := M3UADestinationUserPartUnavailableMessage newMessage.
	self
		fillSSNMMessage: dupuMessage
		forAffectedPointCodes: (OrderedCollection with: anIntegerDPC)
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
		infoString: aString.
	"Add User/Cause parameter"
	dupuMessage
		addTag:
			(M3UATagUserCause
				initDataWithTwoInteger16bits: (Array with: 0 with: anIntegerMTP3User)).
	^ dupuMessage
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
						type: M3UATagMGMTNotifyStatus typeApplicationServerStateChange
						info: M3UATagMGMTNotifyStatus infoAsInactive).
			aRemoteAsp identifier
				ifNotNil:
					[ :id | notifyMsg addTag: (M3UATagASPIdentifier new data: id asByteArray) ].
			aRemoteAsp host handledRoutingContextsIds
				do:
					[ :rc | notifyMsg addTag: (M3UATagRoutingContext initWithInteger32: rc) ].
			notifyMsg
				addTag:
					(M3UATagINFOString fromString: ('NOTIFY : ASP ' , aRemoteAsp name , ' is INACTIVE')).
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
						type: M3UATagMGMTNotifyStatus typeApplicationServerStateChange
						info: as asStateMachine tagNotifyInformation).
			(tagsRoutingContext := aMsgActiveOrInactive
				findAllTags: M3UAConstants tagRoutingContext) isEmpty
				ifFalse: [ tagsRoutingContext do: [ :tagRc | notifyMsg addTag: tagRc ] ].
			notifyMsg
				addTag:
					(M3UATagINFOString
						fromString:
							('NOTIFY : ASP ' , aRemoteAsp name , ' is '
								,
									(aBoolean
										ifTrue: [ 'ACTIVE' ]
										ifFalse: [ 'INACTIVE' ]))).
			^ notifyMsg ].

	"AS state is with insufficient resources"
	as asStateMachine statusInformation
		= M3UAAsStateMachine statusInfoInsufficientResources
		ifTrue: [ notifyMsg
				addTag:
					(M3UATagMGMTNotifyStatus
						type: M3UATagMGMTNotifyStatus typeOther
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
						type: M3UATagMGMTNotifyStatus typeApplicationServerStateChange
						info: M3UATagMGMTNotifyStatus infoAsActive).
			(aMsgActive findTag: M3UAConstants tagRoutingContext) ifNotNil: [ :tagRc | notifyMsg addTag: tagRc ].
			notifyMsg
				addTag:
					(M3UATagINFOString fromString: ('NOTIFY : ASP ' , aRemoteAsp name , ' is ACTIVE')).
			^ notifyMsg ].
		
	"AS state is still INACTIVE with insufficient resources"
	statusInfo = M3UAAsStateMachine statusInfoInsufficientResources 
		ifTrue: [ 
			notifyMsg
				addTag:
					(M3UATagMGMTNotifyStatus
						type: M3UATagMGMTNotifyStatus typeOther
						info: M3UATagMGMTNotifyStatus infoInsufficientASPResourcesActiveInAS).
			notifyMsg
				addTag:
					(M3UATagINFOString new
						data: ('NOTIFY : INSUFFICIENT RESOURCES IN AS ', as name) asByteArray).
			^ notifyMsg  ]
]

{ #category : #'SSNM messages' }
M3UAServerGateway >> createSCONMessageForAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC infoString: aString [
	"Creation of a Signalling Congestion Message"

	| sconMessage |
	sconMessage := M3UASignallingCongestionMessage newMessage.
	self
		fillSSNMMessage: sconMessage
		forAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
		infoString: aString.
	"we don't use Concerned Destination parameter as this message is sent from SGP to ASP,
	and we don't used Congested Indications as it's optional as well"
	^ sconMessage
]

{ #category : #'traffic management' }
M3UAServerGateway >> deactivateRoutingContextId: anIntegerRC [
	trafficManagement dictRoutingContextActivities at: anIntegerRC put: false 
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

{ #category : #'handling RKM messages' }
M3UAServerGateway >> extractRoutingKeyFromTag: aM3UATagRoutingKey [

	| routingKey tagLocalRoutingKeyIdentifier tagRoutingContext tagTrafficModeType tagNetworkAppearance tagServiceIndicators tagOriginatingPointCodeList array tagDestinationPointCode |
	routingKey := M3UARoutingKey new.
	
	"localRKIdentifier"
	tagLocalRoutingKeyIdentifier := aM3UATagRoutingKey findTag: M3UAConstants tagLocalRoutingKeyIdentifier.
	tagLocalRoutingKeyIdentifier ifNotNil: [:tag |  routingKey localRKIdentifier: tag data asInteger].
	
	"routingContext"
	tagRoutingContext := aM3UATagRoutingKey findTag: M3UAConstants tagRoutingContext.
	tagRoutingContext  ifNotNil: [:tag |  routingKey routingContextId: tag data asInteger].

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
M3UAServerGateway >> handleAspActive: aM3UAASPActiveMessage receivedOnSGP: oneOfMySGP [

	"debug"
	self
		logDebug: ' : ACTIVE message received, I will answer it (#handleAspActive:)'.
	"end debug"
	self sendAspActiveAckForMessage: aM3UAASPActiveMessage.

	"debug"
	self logDebug: ' : ACTIVE msg answered (handleAspActive:)'.
	"end debug"

	self
		handleMessage: aM3UAASPActiveMessage
		activeOrInactive: true
		receivedOnSGP: oneOfMySGP
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleAspDown: aM3UAASPDownMessage [

	"debug"
	self logDebug: ' : DOWN message received, I will answer it (#handleAspDown:)'.
	"end debug"
	
	self sendAspDownAckForMessage: aM3UAASPDownMessage.
	
	"debug"
	self logDebug: ' : DOWN message answered (handleAspDown:)'.
	"end debug"

]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleAspInactive: aM3UAASPInactiveMessage receivedOnSGP: oneOfMySGP [

	"debug"
	self logDebug: ' : INACTIVE message received, I will answer it (handleAspInactive:)'.
	"end debug"
	
	self sendAspInactiveAckForMessage: aM3UAASPInactiveMessage.

	"debug"
	self logDebug: ' : INACTIVE message answered (handleAspInactive:)'.
	"end debug"
	
	self
		handleMessage: aM3UAASPInactiveMessage
		activeOrInactive: false
		receivedOnSGP: oneOfMySGP
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> handleAspUp: aM3UAASPUpMessage receivedOnSGP: oneOfMySGP [
	| tagIdentifier remoteAsp dict notifyMessage |
	
	"debug"
	self logDebug: ' : UP message received, I will answer it (handleAspUp:)'.
	"end debug"
	
	self sendAspUpAckForMessage: aM3UAASPUpMessage.

	"debug"
	self logDebug: ' : UP message answered (handleAspUp:)'.
	"end debug"
	
	"Is there an ASP identifier ?"
	tagIdentifier := aM3UAASPUpMessage
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
	dict at: aM3UAASPUpMessage delegateChannel put: remoteAsp.
	
	"debug"
	self logDebug: ' : dict (handleAspUp:) : ', dict printString.
	"end debug"

	"update the AS state machine"
	remoteAsp moveToState: M3UAAspStateInactive.
	
	"put the RC of the remoteAsp to non operational (should be the case already)"
	remoteAsp host handledRoutingContextsIds
		do: [ :anIntegerRC | self deactivateRoutingContextId: anIntegerRC ].
	
	"Create the notify message"
	notifyMessage := self createNotifyMessageForInactivityStatusOfRemoteAsp: remoteAsp.

	"debug"
	self logDebug: ' : notifyMessage (handleAspUp:) : ', notifyMessage class name.
	"end debug"
		
	"Send the notify message"
	oneOfMySGP networkService
		send: notifyMessage
		onChannel: aM3UAASPUpMessage delegateChannel
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> handleDeregistrationRequest: aM3UADeregistrationRequestMessage receivedOnSgp: aSGP [
	"We will create a DEREG RSP message (Deregistration Response)"

	| routingContextTags aspSender deregistrationStatus deregistrationResponseMsg notifyMessage routingContextsIds |
	routingContextTags := aM3UADeregistrationRequestMessage
		findAllTags: M3UAConstants tagRoutingContext.
	routingContextsIds := routingContextTags
		collect: [ :rcTag | rcTag data asInteger ].
	deregistrationStatus := OrderedCollection new.
	aspSender := self
		remoteAspMatchingChannel: aM3UADeregistrationRequestMessage delegateChannel
		ofSGP: aSGP.
	routingContextsIds
		do: [ :rc | 
			| status |
			deregistrationStatus
				addLast: (status := self deregistrationResultForRoutingContext: rc).

			"if the deregistration is OK, we remove the RC"
			status isZero
				ifTrue: [ aspSender
						ifNotNil: [ aspSender host removeAllRoutingKeysOfRoutingContext: rc ] ] ].
				
	
	"create M3UADeregistrationResponseMessage"
	deregistrationResponseMsg := M3UADeregistrationResponseMessage
		newMessage.
	1 to: routingContextsIds size do: [ :i | 
		| resultTag rc deregStatus |
		rc := routingContextsIds at: i.
		deregStatus := deregistrationStatus at: i.
		resultTag := M3UATagDeregistrationResult
			initWithRoutingContextId: rc
			deregistrationStatus: deregStatus.
		deregistrationResponseMsg addTag: resultTag ].

	"send M3UADeregistrationResponseMessage"
	aSGP networkService
		send: deregistrationResponseMsg
		onChannel: aM3UADeregistrationRequestMessage delegateChannel.
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
		onChannel: aM3UADeregistrationRequestMessage delegateChannel
]

{ #category : #'handling SSNM messages' }
M3UAServerGateway >> handleDestinationStateAudit: aM3UADestinationStateAuditMessage receivedOnSGP: aSGP [
	| tagNetworkAppearance tagsRoutingContexts errorMessage tagAffectedPointCode networkAppareance rcs affectedPointCodes unavailablesDestinations dunaMsg congestedDestinations restrictedDestinations userPartUnavailableDestinations sconMsg drstMsg davaMsg dupuMsg aspSender mtp3UsersUnavailable |
	self logDebug: 'handleDestinationStateAudit:receivedOnSGP:  '.
	tagNetworkAppearance := aM3UADestinationStateAuditMessage
		findTag: M3UAConstants tagNetworkAppearance
		ifAbsent: [ nil ].
	tagsRoutingContexts := aM3UADestinationStateAuditMessage
		findAllTags: M3UAConstants tagRoutingContext.
	tagAffectedPointCode := aM3UADestinationStateAuditMessage
		findTag: M3UAConstants tagAffectedPointCode
		ifAbsent: [ errorMessage := self
				createErrorMessageCode: M3UATagMGMTErrorCode missingParameter.
			aSGP networkService
				send: errorMessage
				onChannel: aM3UADestinationStateAuditMessage delegateChannel ].

	"Get the interesting values"
	networkAppareance := tagNetworkAppearance
		ifNil: [ nil ]
		ifNotNil: [ :tag | tag data asInteger ].
	rcs := tagsRoutingContexts collect: [ :tag | tag data asInteger ].
	affectedPointCodes := tagAffectedPointCode affectedPointCodes.

	"Determines which ASP is requesting the DAUD"
	aspSender := self
		remoteAspMatchingChannel: aM3UADestinationStateAuditMessage delegateChannel
		ofSGP: aSGP.

	"First chek if any Destination is unavailable"
	unavailablesDestinations := OrderedCollection new.
	affectedPointCodes
		do: [ :dpc | 
			(trafficManagement
				isDestinationUnavailable: dpc
				networkAppearance: networkAppareance
				routingContextsIds: rcs
				forASP: aspSender)
				ifTrue: [ unavailablesDestinations addLast: dpc ] ].
	unavailablesDestinations isEmpty
		ifFalse: [ dunaMsg := self
				createDUNAMessageForAffectedPointCodes: unavailablesDestinations
				networkAppearance: networkAppareance
				routingContextsIds: rcs
				infoString: nil.
			self logDebug: 'unavailablesDestinations : ' , unavailablesDestinations printString.
			aSGP networkService
				send: dunaMsg
				onChannel: aM3UADestinationStateAuditMessage delegateChannel.
			^ self ].

	"Then chek if there is any congestion"
	congestedDestinations := OrderedCollection new.
	affectedPointCodes
		do: [ :dpc | 
			(trafficManagement
				isExistingCongestionForDestination: dpc
				networkAppearance: networkAppareance
				routingContextsIds: rcs
				forASP: aspSender)
				ifTrue: [ congestedDestinations addLast: dpc ] ].
	congestedDestinations isEmpty
		ifFalse: [ sconMsg := self
				createSCONMessageForAffectedPointCodes: congestedDestinations
				networkAppearance: networkAppareance
				routingContextsIds: rcs
				infoString: nil.
			self logDebug: 'congestedDestinations : ' , congestedDestinations printString.
			aSGP networkService
				send: sconMsg
				onChannel: aM3UADestinationStateAuditMessage delegateChannel.
			^ self ].

	"Then chek if there is any restricted destination"
	restrictedDestinations := OrderedCollection new.
	affectedPointCodes
		do: [ :dpc | 
			(trafficManagement
				isDestinationRestricted: dpc
				networkAppearance: networkAppareance
				routingContextsIds: rcs
				forASP: aspSender)
				ifTrue: [ restrictedDestinations addLast: dpc ] ].
	restrictedDestinations isEmpty
		ifFalse: [ drstMsg := self
				createDRSTMessageForAffectedPointCodes: restrictedDestinations
				networkAppearance: networkAppareance
				routingContextsIds: rcs
				infoString: nil.
			self logDebug: 'restrictedDestinations : ' , restrictedDestinations printString.
			aSGP networkService
				send: drstMsg
				onChannel: aM3UADestinationStateAuditMessage delegateChannel.
			^ self ].

	"Then chek if there is any User Part unavailable destination"
	userPartUnavailableDestinations := OrderedCollection new.
	mtp3UsersUnavailable := OrderedCollection new.
	affectedPointCodes
		do: [ :dpc | 
			(trafficManagement
				mtp3UserUnavailableFor: dpc
				networkAppearance: networkAppareance
				routingContextsIds: rcs
				forASP: aspSender) ifNotNil: [:mtp3User | userPartUnavailableDestinations addLast: dpc. 
					mtp3UsersUnavailable addLast: mtp3User ] ].
	userPartUnavailableDestinations isEmpty
		ifFalse: [ dupuMsg := self
				createDUPUMessageForAffectedPointCode: userPartUnavailableDestinations first
				mtp3User: mtp3UsersUnavailable first
				networkAppearance: networkAppareance
				routingContextsIds: rcs
				infoString: nil.
			self logDebug: 'userPartUnavailableDestinations : ', userPartUnavailableDestinations printString.
			aSGP networkService
				send: dupuMsg
				onChannel: aM3UADestinationStateAuditMessage delegateChannel.
			^ self ].

	"The traffic is OK, we can send a DAVA message"
	davaMsg := self
		createDAVAMessageForAffectedPointCodes: affectedPointCodes
		networkAppearance: networkAppareance
		routingContextsIds: rcs
		infoString: nil.
	self logDebug: 'availableDestinations : ' , affectedPointCodes printString.
	aSGP networkService
		send: davaMsg
		onChannel: aM3UADestinationStateAuditMessage delegateChannel
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
		ifTrue: [ rcs addAllLast: remoteAsp host handledRoutingContextsIds ].

	"update the RC(s) of the remoteAsp to operational/non-operational"
	unknownAspRCs := OrderedCollection new.
	rcs
		do: [ :rc | 
			(remoteAsp host handledRoutingContextsIds includes: rc)
				ifTrue: [ self activeOrDeactive: aBoolean routingContext: rc ]
				ifFalse: [ unknownAspRCs addLast: rc ] ].
			
	"Send an error message if routing context(s) is(are) unknown"
	unknownAspRCs isEmpty
		ifFalse: [ errorMessage := self
				createErrorMessageCode: M3UATagMGMTErrorCode invalidRoutingContextValue.
			unknownAspRCs
				do: [ :rc | 
					errorMessage
						addTag: (M3UATagRoutingContext initDataWithOneInteger32bits: rc) ] ].

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

{ #category : #'handling TRANSFER messages' }
M3UAServerGateway >> handlePayloadDataMessage: aM3UAPayloadDataMessage receivedOnLogicalProcess: aSGP [
	| tagNetworkAppearance tagRoutingContext tagProtocolData dpc networkAppearance dunaMsg routingContexts aspSender payloadData |
	tagNetworkAppearance := aM3UAPayloadDataMessage
		findTag: M3UAConstants tagNetworkAppearance
		ifAbsent: [ nil ].
	tagRoutingContext := aM3UAPayloadDataMessage
		findTag: M3UAConstants tagRoutingContext
		ifAbsent: [ nil ].
	tagProtocolData := aM3UAPayloadDataMessage
		findTag: M3UAConstants tagProtocolData.
	routingContexts := OrderedCollection new.
	tagRoutingContext
		ifNotNil: [ :tag | routingContexts addLast: tag data asInteger ].

	"Determines which ASP is sending the Payload data"
	aspSender := self
		remoteAspMatchingChannel: aM3UAPayloadDataMessage delegateChannel
		ofSGP: aSGP.

	"Check the traffic"
	(trafficManagement
		isDestinationUnavailable: (dpc := tagProtocolData dpcField)
		networkAppearance:
			(networkAppearance := tagNetworkAppearance
				ifNil: [ nil ]
				ifNotNil: [ :tag | tag data asInteger ])
		routingContextsIds: routingContexts
		forASP: aspSender)
		ifTrue: [ dunaMsg := self
				createDUNAMessageForAffectedPointCodes: (OrderedCollection with: dpc)
				networkAppearance: networkAppearance
				routingContextsIds: routingContexts
				infoString: 'Destination Point Code ' , dpc printString , ' is unavailable'.
			aSGP networkService
				send: dunaMsg
				onChannel: aM3UAPayloadDataMessage delegateChannel ].

	"Destination is available"
	payloadData := PayloadData fromMessage: aM3UAPayloadDataMessage.
	layerManagement performMTPTransferRequestPrimitiveWith: payloadData.

]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> handleRegistrationRequest: aM3UARegistrationRequestMessage receivedOnSgp: aSGP [
	"We will create a REG RSP message (Registration Response)"

	| routingKeyTags routingKeys registrationStatus registrationResponseMsg aspSender notifyMessage |
	routingKeyTags := aM3UARegistrationRequestMessage
		findAllTags: M3UAConstants tagRoutingKey.
	routingKeys := OrderedCollection new.
	registrationStatus := OrderedCollection new.
	aspSender := self
		remoteAspMatchingChannel: aM3UARegistrationRequestMessage delegateChannel
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
								forRoutingContextId: routingKey routingContextId ] ] ].

	"create M3UARegistrationResponseMessage"
	registrationResponseMsg := M3UARegistrationResponseMessage newMessage.
	1 to: routingKeys size do: [ :i | 
		| resultTag rk regStatus |
		rk := routingKeys at: i.
		regStatus := registrationStatus at: i.
		resultTag := M3UATagRegistrationResult
			initWithLocalRKIdentifier: rk localRKIdentifier
			registrationStatus: regStatus
			routingContextId: rk routingContextId.
		registrationResponseMsg addTag: resultTag ].

	"send M3UARegistrationResponseMessage"
	aSGP networkService
		send: registrationResponseMsg
		onChannel: aM3UARegistrationRequestMessage delegateChannel.
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
		onChannel: aM3UARegistrationRequestMessage delegateChannel
]

{ #category : #initialization }
M3UAServerGateway >> initialize [
	super initialize.
	remoteApplicationServers := OrderedCollection new.
	dictChannelsForRemoteAspsBySGP := Dictionary new.
	trafficManagement := M3UAServerGatewayTrafficManagement new.
	layerManagement := M3UASGLayerManagement on: self
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

{ #category : #'traffic management' }
M3UAServerGateway >> isRoutingContextActive: anIntegerRC [
	^ trafficManagement dictRoutingContextActivities
		at: anIntegerRC
		ifAbsent: [ false ]
]

{ #category : #testing }
M3UAServerGateway >> isServerGateway [
	^ true
]

{ #category : #'handling RKM messages' }
M3UAServerGateway >> isValidRoutingKey: aM3UAoutingKey errorStream: aStream [
	"Cases to test :
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
	anM3UAApplicationServer handledRoutingContextsIds
		do: [ :rc | self deactivateRoutingContextId: rc ]
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

{ #category : #mockup }
M3UAServerGateway >> removeDestination: anIntegerDPC [
	remoteApplicationServers
		do: [ :as | as trafficManagement removeDestination: anIntegerDPC ]
]

{ #category : #mockup }
M3UAServerGateway >> restrictedDestination: anIntegerDPC [
	"Simulate a restriction for a Destination Point Code"

	remoteApplicationServers
		do: [ :as | as trafficManagement restrictedDestination: anIntegerDPC ]
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
	ack addTag: (M3UATagINFOString fromString: 'ASP ACTIVE message ACKED').

	"Send the ACK"
	self replyToMessage: aMsgActive withACK: ack
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> sendAspDownAckForMessage: aMsgDown [
	| ack |
	
	"ACK message creation"
	ack := M3UAASPDownAckMessage newMessage
		addTag:
			(M3UATagINFOString fromString: ('ASP DOWN message ACKED'));
		yourself.
		
	"Send the ACK"	
	self replyToMessage: aMsgDown withACK: ack
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> sendAspInactiveAckForMessage: aMsgInactive [
	| ack |
	
	"ACK message creation"
	ack := M3UAASPInactiveAckMessage newMessage
		addTag: (M3UATagINFOString fromString: 'ASP INACTIVE message ACKED');
		yourself.

	"Send the ACK"
	self replyToMessage: aMsgInactive withACK: ack
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UAServerGateway >> sendAspUpAckForMessage: aMsgUp [
	| ack |
	
	"ACK message creation"
	ack := M3UAASPUpAckMessage newMessage
		addTag: (M3UATagINFOString fromString: ('ASP UP message ACKED'));
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

{ #category : #mockup }
M3UAServerGateway >> unavailableDestination: anIntegerDPC [
	"Simulate an unavaibility for a Destination Point Code"

	remoteApplicationServers
		do: [ :as | as trafficManagement unavailableDestination: anIntegerDPC ]
]

{ #category : #mockup }
M3UAServerGateway >> userPartISUPUnavailableDestination: anIntegerDPC [
	"Simulate a ISUP unavaibility for a Destination Point Code"

	self
		userPartUnavailableDestination: anIntegerDPC
		mtp3User:
			(M3UADestinationUserPartUnavailableMessage dictionaryMTP3UserIdentity
				at: 'ISUP')
]

{ #category : #mockup }
M3UAServerGateway >> userPartSCCPUnavailableDestination: anIntegerDPC [
	"Simulate a SCCP unavaibility for a Destination Point Code"

	self
		userPartUnavailableDestination: anIntegerDPC
		mtp3User:
			(M3UADestinationUserPartUnavailableMessage dictionaryMTP3UserIdentity
				at: 'SCCP')
]

{ #category : #mockup }
M3UAServerGateway >> userPartUnavailableDestination: anIntegerDPC mtp3User: anOtherInteger [
	"Simulate a Use Part unavaibility for a Destination Point Code"

	remoteApplicationServers
		do: [ :as | 
			as trafficManagement
				userPartUnavailableDestination: anIntegerDPC
				mtp3User: anOtherInteger ]
]
