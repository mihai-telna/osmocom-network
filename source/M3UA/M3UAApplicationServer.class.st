Class {
	#name : #M3UAApplicationServer,
	#superclass : #M3UALogicalEntity,
	#instVars : [
		'asStateMachine',
		'currentAsp',
		'lastPayloadReceived'
	],
	#category : #'M3UA-Core'
}

{ #category : #'traffic management' }
M3UAApplicationServer >> addRoutingKey: aM3UARoutingKey forRoutingContextId: anInteger [
	trafficManagement
		addRoutingKey: aM3UARoutingKey
		forRoutingContextId: anInteger
]

{ #category : #accessing }
M3UAApplicationServer >> asStateMachine [
	^ asStateMachine
]

{ #category : #'traffic management' }
M3UAApplicationServer >> auditMessageForDestinations: aCollectionOfIntegerDPC routingContextsIds: aCollectionOfIntegerRC [
	^ self
		createDAUDMessageForAffectedPointCodes: aCollectionOfIntegerDPC
		networkAppearance: nil
		routingContextsIds: aCollectionOfIntegerRC
		infoString: nil
]

{ #category : #'traffic management' }
M3UAApplicationServer >> auditMessageForUnavailableDestinations [
	^ self
		createDAUDMessageForAffectedPointCodes: trafficManagement unavailableDestinations
		networkAppearance: nil
		routingContextsIds:
			(trafficManagement unavailableRoutingContexts
				collect: [ :rc | rc routingContextId ])
		infoString: nil
]

{ #category : #'process searching' }
M3UAApplicationServer >> chooseCurrentAsp [
	| indexCurrent |
	self trafficModeName = 'Loadshare'
		ifTrue: [ indexCurrent := currentAsp
				ifNil: [ 0 ]
				ifNotNil: [ self registeredAsps indexOf: currentAsp ].
			currentAsp := self registeredAsps
				at:
					(indexCurrent = self registeredAsps size
						ifTrue: [ 1 ]
						ifFalse: [ indexCurrent + 1 ]) ]
		ifFalse: [ self flag: #todo.
			currentAsp := self registeredAsps first ].
	^ currentAsp
]

{ #category : #'process searching' }
M3UAApplicationServer >> chooseProcess [
	^ self chooseCurrentAsp
]

{ #category : #'SSNM messages' }
M3UAApplicationServer >> createDAUDMessageForAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC infoString: aString [
	"Creation of a Destination State Audit Message"

	| daudMessage |
	daudMessage := M3UADestinationStateAuditMessage newMessage.
	self
		fillSSNMMessage: daudMessage
		forAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
		infoString: aString.
	^ daudMessage
]

{ #category : #'handling RKM messages' }
M3UAApplicationServer >> handleDeregistrationResponse: aM3UADeregistrationResponseMessage [
	self flag: #todo
]

{ #category : #'handling SSNM messages' }
M3UAApplicationServer >> handleDestinationAvailable: aM3UADestinationAvailableMessage receivedOnAsp: anASP [
	| tagNetworkAppareance tagRoutingContexts tagAffectedPointCodes affectedPointCodes routingContextsIds networkAppareance |
	tagNetworkAppareance := aM3UADestinationAvailableMessage
		findTag: M3UAConstants tagNetworkAppearance.
	tagRoutingContexts := aM3UADestinationAvailableMessage
		findAllTags: M3UAConstants tagRoutingContext.
	tagAffectedPointCodes := aM3UADestinationAvailableMessage
		findTag: M3UAConstants tagAffectedPointCode.

	"manage the traffic"
	trafficManagement
		handleAvailableDestinations: (affectedPointCodes := tagAffectedPointCodes affectedPointCodes)
		routingContextsIds:
			(routingContextsIds := tagRoutingContexts
				collect: [ :rc | rc data asInteger ])
		networkAppareance:
			(networkAppareance := tagNetworkAppareance
				ifNil: [ nil ]
				ifNotNil: [ :tag | tag data asInteger ]).

	"The Layer Management will perform a MTP-RESUME indication"
	layerManagement
		performMTPResumeIndicationPrimitiveForAffectedPointCodes: affectedPointCodes
		routingContextsIds: routingContextsIds
		networkAppareance: networkAppareance.
		
	"Stop sending DAUD periodically"
	anASP disableDAUDScheduler 
]

{ #category : #'handling SSNM messages' }
M3UAApplicationServer >> handleDestinationRestricted: aM3UADestinationRestrictedMessage [
	| tagNetworkAppareance tagRoutingContexts tagAffectedPointCodes |
	tagNetworkAppareance := aM3UADestinationRestrictedMessage
		findTag: M3UAConstants tagNetworkAppearance.
	tagRoutingContexts := aM3UADestinationRestrictedMessage
		findAllTags: M3UAConstants tagRoutingContext.
	tagAffectedPointCodes := aM3UADestinationRestrictedMessage
		findTag: M3UAConstants tagAffectedPointCode.
		
	"manage the traffic"
	trafficManagement
		handleRestrictedDestinations: tagAffectedPointCodes affectedPointCodes
		routingContextsIds: (tagRoutingContexts collect: [ :rc | rc data asInteger ])
		networkAppareance:
			(tagNetworkAppareance
				ifNil: [ nil ]
				ifNotNil: [ :tag | tag data asInteger ])
]

{ #category : #'handling SSNM messages' }
M3UAApplicationServer >> handleDestinationUnavailable: aM3UADestinationUnavailableMessage receivedOnAsp: anASP [ 
	| tagNetworkAppareance tagRoutingContexts tagAffectedPointCodes affectedPointCodes routingContextsIds networkAppareance daudMessage |
	tagNetworkAppareance := aM3UADestinationUnavailableMessage
		findTag: M3UAConstants tagNetworkAppearance.
	tagRoutingContexts := aM3UADestinationUnavailableMessage
		findAllTags: M3UAConstants tagRoutingContext.
	tagAffectedPointCodes := aM3UADestinationUnavailableMessage
		findTag: M3UAConstants tagAffectedPointCode.

	"manage the traffic"
	trafficManagement
		handleUnavailableDestinations: (affectedPointCodes := tagAffectedPointCodes affectedPointCodes)
		routingContextsIds:
			(routingContextsIds := tagRoutingContexts
				collect: [ :rc | rc data asInteger ])
		networkAppareance:
			(networkAppareance := tagNetworkAppareance
				ifNil: [ nil ]
				ifNotNil: [ :tag | tag data asInteger ]).

	"The Layer Management will perform a MTP-PAUSE indication"
	layerManagement
		performMTPPauseIndicationPrimitiveForAffectedPointCodes: affectedPointCodes
		routingContextsIds: routingContextsIds
		networkAppareance: networkAppareance.
		
	"Start sending a DAUD perodically"
	self logDebug: 'Ask for sending DAUD periodically for unavailable destinations ', trafficManagement unavailableDestinations printString, ' at ', Time now printString.
	daudMessage := self auditMessageForUnavailableDestinations.
	anASP sendDAUDMessageToPeer: daudMessage inReplyToMessage: aM3UADestinationUnavailableMessage
]

{ #category : #'handling SSNM messages' }
M3UAApplicationServer >> handleDestinationUserPartUnavailable: aM3UADestinationUserPartUnavailableMessage [
	| tagNetworkAppearance tagRoutingContexts tagAffectedPointCodes tagCause affectedPointCode mtp3User routingContextsIds networkAppareance |
	tagNetworkAppearance := aM3UADestinationUserPartUnavailableMessage
		findTag: M3UAConstants tagNetworkAppearance.
	tagRoutingContexts := aM3UADestinationUserPartUnavailableMessage
		findAllTags: M3UAConstants tagRoutingContext.
	tagAffectedPointCodes := aM3UADestinationUserPartUnavailableMessage
		findTag: M3UAConstants tagAffectedPointCode.
	tagCause := aM3UADestinationUserPartUnavailableMessage
		findTag: M3UAConstants tagUserCause.
		
	"manage the traffic"
	trafficManagement
		handleUserPartUnavailableDestination: (affectedPointCode := tagAffectedPointCodes affectedPointCodes first)
		mtp3User: (mtp3User := tagCause mtp3UserIdentityField)
		routingContextsIds:
			(routingContextsIds := tagRoutingContexts
				collect: [ :rc | rc data asInteger ])
		networkAppareance:
			(networkAppareance := tagNetworkAppearance
				ifNil: [ nil ]
				ifNotNil: [ :tag | tag data asInteger ]).

	"The Layer Management will perform a MTP-STATUS indication"
	layerManagement
		performMTPUserPartUnavailableStatusIndicationPrimitiveForAffectedPointCode: affectedPointCode
		mtp3User: mtp3User
		routingContextsIds: routingContextsIds
		networkAppareance: networkAppareance
]

{ #category : #'handling TRANSFER messages' }
M3UAApplicationServer >> handlePayloadDataMessage: aM3UAPayloadDataMessage receivedOnLogicalProcess: anASP [

	| tagProtocolData errorMessage payloadData |
	tagProtocolData := aM3UAPayloadDataMessage
		findTag: M3UAConstants tagProtocolData
		ifAbsent: [ errorMessage := self
				createErrorMessageCode: M3UATagMGMTErrorCode unsupportedMessageType .
				anASP networkService  send: errorMessage
		onChannel: aM3UAPayloadDataMessage delegateChannel].
	
	"MTP-TRANSFER Indication Primitive"
	payloadData := PayloadData fromMessage: aM3UAPayloadDataMessage.
	layerManagement performMTPTransferIndicationPrimitiveWith: payloadData.
	
	"LINK TO ROAMING HUB
	(maybe to put in the layerManagement/MTP-TRANSFER Indication Primitive ?)"
	tagProtocolData isSCCP
		ifTrue: [ ^ anASP networkService
				signalUnitData: tagProtocolData userProtocolData
				fromOpc: tagProtocolData opcField
				toDpc: tagProtocolData dpcField
				priority: tagProtocolData mpField ] ifFalse: [self flag: #todo].

]

{ #category : #'handling RKM messages' }
M3UAApplicationServer >> handleRegistrationResponse: aM3UARegistrationResponseMessage [
	self flag: #todo
]

{ #category : #'handling SSNM messages' }
M3UAApplicationServer >> handleSignallingCongestion: aM3UASignallingCongestionMessage [
	| tagNetworkAppareance tagRoutingContexts tagAffectedPointCodes affectedPointCodes routingContextsIds networkAppareance |
	tagNetworkAppareance := aM3UASignallingCongestionMessage
		findTag: M3UAConstants tagNetworkAppearance.
	tagRoutingContexts := aM3UASignallingCongestionMessage
		findAllTags: M3UAConstants tagRoutingContext.
	tagAffectedPointCodes := aM3UASignallingCongestionMessage
		findTag: M3UAConstants tagAffectedPointCode.

	"manage the traffic"
	trafficManagement
		handleCongestedDestinations: (affectedPointCodes := tagAffectedPointCodes affectedPointCodes)
		routingContextsIds:
			(routingContextsIds := tagRoutingContexts
				collect: [ :rc | rc data asInteger ])
		networkAppareance:
			(networkAppareance := tagNetworkAppareance
				ifNil: [ nil ]
				ifNotNil: [ :tag | tag data asInteger ]).

	"The Layer Management will perform a MTP-STATUS indication"
	layerManagement
		performMTPCongestionStatusIndicationPrimitiveForAffectedPointCodes: affectedPointCodes
		routingContextsIds: routingContextsIds
		networkAppareance: networkAppareance
]

{ #category : #'traffic management' }
M3UAApplicationServer >> handledRoutingContexts [
	^ trafficManagement routingContexts
]

{ #category : #'traffic management' }
M3UAApplicationServer >> handledRoutingContextsIds [
	^ trafficManagement routingContextsIds
]

{ #category : #initialization }
M3UAApplicationServer >> initialize [
	super initialize.
	asStateMachine := M3UAAsStateMachine new.
	asStateMachine aspStateMachines: OrderedCollection new.
	trafficManagement := M3UAApplicationServerTrafficManagement new.
	layerManagement := M3UAASLayerManagement on: self
]

{ #category : #testing }
M3UAApplicationServer >> isServerGateway [
	^ false
]

{ #category : #accessing }
M3UAApplicationServer >> lastPayloadReceived [
	^ lastPayloadReceived
]

{ #category : #routing }
M3UAApplicationServer >> networkService: aM3UANetworkService [
	"To put in class RHCentralForM3UA after tests validation.
	The calls to the method #signalUnitData:  should be done only for Transfer messages"

	self flag: #todo.
	aM3UANetworkService
		onUnitData:
			[ :data :opc :dpc :priority | self routeM3UAMData: data fromOpc: opc dpc: dpc ]
]

{ #category : #initialization }
M3UAApplicationServer >> registerASP: aM3UAApplicationServerProcess [
	aM3UAApplicationServerProcess host: self.
	
	"Add to the ASP list"
	self registeredAsps addLast: aM3UAApplicationServerProcess.
			
	"Link states machines"
	asStateMachine aspStateMachines
		addLast: aM3UAApplicationServerProcess aspStateMachine.
	asStateMachine
		handleAnnouncementFor: aM3UAApplicationServerProcess aspStateMachine
]

{ #category : #access }
M3UAApplicationServer >> registeredAsps [
	^ registeredProcesses
]

{ #category : #'traffic management' }
M3UAApplicationServer >> removeAllRoutingKeysOfRoutingContext: anInteger [
	trafficManagement removeAllRoutingKeysOfRoutingContext: anInteger
]

{ #category : #routing }
M3UAApplicationServer >> routeM3UAMData: aByteArray fromOpc: opc dpc: dpc [
	"To do : use a M3URouter to pass the message to the RHCentral"

	lastPayloadReceived := aByteArray
]

{ #category : #sending }
M3UAApplicationServer >> targetPeerForASP: oneOfMyAsp [
	^ configuration targetPeerForASP: oneOfMyAsp
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> trafficModeName [
	"Note : Round-Robin is a sub-mode of Loadshare"

	| trafficModeType |
	(trafficModeType := configuration trafficModeType) = 1
		ifTrue: [ ^ 'Override' ].
	trafficModeType = 2
		ifTrue: [ ^ 'Loadshare' ].
	trafficModeType = 3
		ifTrue: [ ^ 'Broadcast' ]
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> trafficModeType [
	"Note : Round-Robin is a sub-mode of Loadshare"

	^ configuration trafficModeType
]
