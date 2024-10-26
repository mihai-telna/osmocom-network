Class {
	#name : #M3UALogicalEntity,
	#superclass : #M3UAEntity,
	#instVars : [
		'name',
		'registeredProcesses',
		'layerManagement',
		'pointCode',
		'configuration',
		'lastNotifyMessageReceived',
		'lastErrorMessageReceived',
		'trafficManagement'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
M3UALogicalEntity class >> name: aString [
	^ self new
		name: aString;
		yourself
]

{ #category : #'process searching' }
M3UALogicalEntity >> chooseProcess [
	^ self subclassResponsibility
]

{ #category : #'process searching' }
M3UALogicalEntity >> chooseProcessForReplyingAnAckToMessage: aReceivedMessage [
	"By default, we choose the same ASP that has received the message"

	^ aReceivedMessage logicalProcessReceiver
]

{ #category : #accessing }
M3UALogicalEntity >> configuration [
	^ configuration
]

{ #category : #accessing }
M3UALogicalEntity >> configuration: anObject [
	configuration := anObject
]

{ #category : #'Primitives MTP3-User (creation)' }
M3UALogicalEntity >> createAndSendM3UAPayloadDataMessageFor: aPayloadData toLogicalProcess: aLogicalProcess [
	| payloadMessage |
	payloadMessage := self
		createTransferMessageWithPayloadData: aPayloadData.
	self chooseProcess sendMessage: payloadMessage toPeer: aLogicalProcess
]

{ #category : #sending }
M3UALogicalEntity >> createErrorMessageCode: anInteger [
	^ M3UAErrorMessage newMessage
		addTag: (M3UATagMGMTErrorCode initWithData: anInteger asByteArray);
		yourself
]

{ #category : #'Primitives MTP3-User (creation)' }
M3UALogicalEntity >> createTransferMessageWithPayloadData: aPayloadData [
	| msg routingContextTag protocolDataTag networkAppearanceTag correlationIdTag |
	msg := M3UAPayloadDataMessage newMessage.
	aPayloadData networkAppearance
		ifNotNil: [ :anIntegerNA | 
			networkAppearanceTag := M3UATagNetworkAppearance
				initWithInteger32: anIntegerNA.
			msg addTag: networkAppearanceTag ].
	aPayloadData routingContextId
		ifNotNil: [ :anIntegerRC | 
			routingContextTag := M3UATagRoutingContext
				initWithInteger32: anIntegerRC.
			msg addTag: routingContextTag ].
	protocolDataTag := M3UATagProtocolData
		userData: aPayloadData data
		opc: aPayloadData opc
		dpc: aPayloadData dpc
		si: aPayloadData serviceIndicator
		ni: aPayloadData networkIndicator
		mp: aPayloadData messagePriority
		sls: aPayloadData sls.
	msg addTag: protocolDataTag.
	aPayloadData correlationId
		ifNotNil: [ :anIntegerCid | 
			correlationIdTag := M3UATagCorrelationID
				initWithInteger32: anIntegerCid.
			msg addTag: correlationIdTag ].
	^ msg
]

{ #category : #'SSNM messages' }
M3UALogicalEntity >> fillSSNMMessage: aSSNMMessage forAffectedPointCodes: aCollectionOfApc networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC infoString: aString [
	anIntegerNA
		ifNotNil: [ aSSNMMessage
				addTag: (M3UATagNetworkAppearance initWithInteger32: anIntegerNA) ].
	aCollectionOfIntegerRC
		do: [ :anIntegerRC | 
			aSSNMMessage
				addTag: (M3UATagRoutingContext initWithInteger32: anIntegerRC) ].
	aSSNMMessage
		addTag:
			(M3UATagAffectedPointCode
				initDataWithNInteger24bits: aCollectionOfApc
				paddingFirstWith: (aCollectionOfApc collect: [ :opc | 0 ])).
	aString
		ifNotNil: [ aSSNMMessage addTag: (M3UATagINFOString fromString: aString) ]
]

{ #category : #'process searching' }
M3UALogicalEntity >> findProcessWithIdentifier: aByteArray [
	"We are looking for an ASP/SGP within our own registered ASPs/DGPs"

	registeredProcesses
		do: [ :aspOrSgp | 
			aspOrSgp identifier = aByteArray asArray
				ifTrue: [ ^ aspOrSgp ] ]
]

{ #category : #'handling ASPTM ASPSM messages' }
M3UALogicalEntity >> handleAspHeartbeat: aM3UAASPHeartbeatMessage [

	"debug"
	self logDebug: ' : HEARTBEAT message received, I will answer it (#handleAspHeartbeat:)'.
	"end debug"
	
	self sendAspHeartbeatAckForMessage: aM3UAASPHeartbeatMessage
]

{ #category : #'handling TRANSFER messages' }
M3UALogicalEntity >> handlePayloadDataMessage: aM3UAPayloadDataMessage receivedOnLogicalProcess: anASP [
	self subclassResponsibility
]

{ #category : #initialization }
M3UALogicalEntity >> initialize [ 
	super initialize.
	registeredProcesses := OrderedCollection new.
	name := ''
]

{ #category : #accessing }
M3UALogicalEntity >> lastErrorMessageReceived [
	^ lastErrorMessageReceived
]

{ #category : #accessing }
M3UALogicalEntity >> lastNotifyMessageReceived [
	^ lastNotifyMessageReceived
]

{ #category : #accessing }
M3UALogicalEntity >> layerManagement [
	^ layerManagement
]

{ #category : #accessing }
M3UALogicalEntity >> layerManagement: anObject [
	layerManagement := anObject
]

{ #category : #debug }
M3UALogicalEntity >> logDebug: aString [
	self logDebug: self name , ' : ' , aString area: #m3ua
]

{ #category : #accessing }
M3UALogicalEntity >> name [
	^ name
]

{ #category : #accessing }
M3UALogicalEntity >> name: anObject [
	name := anObject
]

{ #category : #'messages creation' }
M3UALogicalEntity >> notifyMessageStatus: anIntegerStatus identifier: aByteArray routingContext: anIntegerRC string: aString [
	| msg |
	msg := M3UANotifyMessage newMessage.
	msg
		addTag:
			(M3UATagMGMTNotifyStatus
				type: M3UATagMGMTNotifyStatus typeApplicationServerStateChange
				info: anIntegerStatus).
	aByteArray
		ifNotNil: [ msg addTag: (M3UATagASPIdentifier new data: aByteArray) ].
	anIntegerRC
		ifNotNil: [ msg addTag: (M3UATagRoutingContext initWithInteger32: anIntegerRC) ].
	aString
		ifNotNil: [ msg addTag: (M3UATagINFOString fromString: aString) ].
	^ msg
]

{ #category : #accessing }
M3UALogicalEntity >> pointCode [
	^ pointCode
]

{ #category : #accessing }
M3UALogicalEntity >> pointCode: anObject [
	pointCode := anObject
]

{ #category : #miscellaneous }
M3UALogicalEntity >> receiveErrorMessage: aM3UAErrorMessage [
	"I have received an error message forworded by one of my ASP"
	
	lastErrorMessageReceived := aM3UAErrorMessage
]

{ #category : #miscellaneous }
M3UALogicalEntity >> receiveNotifyMessage: aM3UANotifyMessage [
	"I have received a notify message forworded by one of my ASP"
	
	lastNotifyMessageReceived := aM3UANotifyMessage
]

{ #category : #sending }
M3UALogicalEntity >> replyToMessage: aMsg withACK: aMsgACK [
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
M3UALogicalEntity >> sendAspHeartbeatAckForMessage: aM3UAASPHeartbeatMessage [
	| ack |
	
	"ACK message creation"
	ack := M3UAASPHeartbeatAckMessage newMessage
		addTag: (aM3UAASPHeartbeatMessage findTag: M3UAConstants tagHeartbeatData);
		yourself.

	"Send the ACK"
	self replyToMessage: aM3UAASPHeartbeatMessage withACK: ack
]

{ #category : #accessing }
M3UALogicalEntity >> trafficManagement [
	^ trafficManagement
]
