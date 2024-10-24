Class {
	#name : #M3UAApplicationServerProcessTest,
	#superclass : #TestCase,
	#instVars : [
		'sg',
		'as'
	],
	#category : #'M3UA-Tests'
}

{ #category : #access }
M3UAApplicationServerProcessTest class >> fakeNetworkAppearance [
	^ 777
]

{ #category : #frames }
M3UAApplicationServerProcessTest class >> m3uaAspAcAckFrame [
	^ByteArray readHexFrom: '0100040300000018000b0008000000020006000800000038'
]

{ #category : #frames }
M3UAApplicationServerProcessTest class >> m3uaAspUpAckFrame [
	^ByteArray readHexFrom: '0100030400000008'
]

{ #category : #frames }
M3UAApplicationServerProcessTest class >> m3uaAspUpFrame [
	^ByteArray readHexFrom: '0100030100000008'
]

{ #category : #frames }
M3UAApplicationServerProcessTest class >> m3uaNotifyFrame [
	^ByteArray readHexFrom: '0100000100000018000d0008000100030006000800000038'
]

{ #category : #access }
M3UAApplicationServerProcessTest class >> routingKeysWithTrafficModeType: anInteger [
	| rc1Id rc2Id routingKey1 routingKey2 |
	rc1Id := 12345.
	rc2Id := 67890.
	
	routingKey1 := M3UARoutingKey dpc: 11111.
	routingKey1 localRKIdentifier: 1.
	routingKey1 listOpc: (OrderedCollection with: 33333 with: 44444).
	routingKey1 routingContextId: rc1Id.
	routingKey1 trafficModeType: anInteger.
	routingKey1 serviceIndicators: #(12 34).
	routingKey1 networkAppearance: self fakeNetworkAppearance.
	
	routingKey2 := M3UARoutingKey dpc: 22222.
	routingKey2 localRKIdentifier: 2.
	routingKey2 listOpc: (OrderedCollection with: 55555 with: 66666).
	routingKey2 routingContextId: rc2Id.
	routingKey2 trafficModeType: anInteger.
	routingKey2 serviceIndicators: #(45 56).
	routingKey2 networkAppearance: self fakeNetworkAppearance.
	
	^ OrderedCollection with: routingKey1 with: routingKey2
]

{ #category : #configuration }
M3UAApplicationServerProcessTest >> copyOfApplicationServer: anAS [
	"We duplicate the data needed to know for the server gateway :
		- AS registered ASPS (name and identifier only)
		- AS point code
	We must not copy the AS state machine "

	| newAS |
	newAS := M3UAApplicationServer name: anAS name.
	newAS pointCode: anAS pointCode.
	anAS registeredAsps
		do: [ :asp | 
			| newAsp |
			newAsp := M3UAApplicationServerProcess
				name: asp name
				identifier: asp identifier.
			newAS registerASP: newAsp ].		
		
	newAS asStateMachine
		requiredNumberOfAsps: as asStateMachine requiredNumberOfAsps.
	newAS asStateMachine
		recoveryTimerDelayMax: as asStateMachine recoveryTimerDelayMax.
	^ newAS
]

{ #category : #configuration }
M3UAApplicationServerProcessTest >> createFakePayloadDataWith: aByteArray [
	^ PayloadData new
		data: aByteArray;
		networkAppearance: self class fakeNetworkAppearance;
		routingContextId: 29384;
		opc: 61;
		dpc: 20;
		serviceIndicator: 3;
		networkIndicator: 3;
		messagePriority: 0;
		sls: 9;
		correlationId: 28;
		yourself
]

{ #category : #configuration }
M3UAApplicationServerProcessTest >> createFakePayloadDataWith: aByteArray opc: anIntegerOPC dpc: anIntegerDPC routingContextId: anIntegerRC logicalProcess: aLogicalProcess [
	^ PayloadData new
		data: aByteArray;
		networkAppearance: self class fakeNetworkAppearance;
		routingContextId: anIntegerRC;
		opc: anIntegerOPC;
		dpc: anIntegerDPC;
		serviceIndicator: 3;
		networkIndicator: 3;
		messagePriority: 0;
		sls: 9;
		correlationId: 28;
		yourself
]

{ #category : #configuration }
M3UAApplicationServerProcessTest >> initApplicationServerWithNumberOfASP: anInteger withDynamicRegistration: aBoolean [
	| networkServiceAs asConfiguration routingKeys |
	routingKeys := OrderedCollection new.

	"Application server"
	networkServiceAs := M3UANetworkServiceOsmoDirect new.
	networkServiceAs
		hostname: 'localhost'
		port: self portServerGatewayOne.
	as := (M3UAApplicationServer name: 'AS 1')
		networkService: networkServiceAs;
		yourself.
	1 to: anInteger do: [ :i | 
		| aspI |
		aspI := M3UAApplicationServerProcess
			name: as name , '/ASP' , i printString
			identifier:
				(Array
					with: i
					with: i * 2
					with: i * 3
					with: i * 4).
		aspI initWith: networkServiceAs.
		as registerASP: aspI ].

	"configuration AS"
	asConfiguration := M3UAASConfiguration
		onApplicationServer: as
		requiredNumberOfAsps: 1
		recoveryTimerDelayMax: 5.

	"static registration"
	aBoolean
		ifFalse: [ (self routingKeysForStaticRegistrationForAS: as)
				do: [ :rK | as addRoutingKey: rK forRoutingContextId: rK routingContextId ] ].
	^ as
]

{ #category : #configuration }
M3UAApplicationServerProcessTest >> initForDirectConnectionAndNumberOfASPForAS: anInteger withDynamicRegistration: aBoolean [
	| networkServiceSG spg sgConfiguration arraySG asConfiguration newAS |
	
	"Server gateway"
	arraySG := self initServerGatewayOne.
	sg := arraySG first.
	spg := arraySG last.
	networkServiceSG := spg networkService.

	"Application server"
	as := self
		initApplicationServerWithNumberOfASP: anInteger
		withDynamicRegistration: aBoolean.
	asConfiguration := as configuration.

	"Update configuration with peers"
	asConfiguration addRemoteTargetPeer: spg.
	as registeredAsps
		do: [ :asp | asConfiguration addRemoteTargetPeer: spg forASP: asp ].

	"the SG must be aware of the AS"
	sg
		registerRemoteApplicationServer:
			(newAS := self copyOfApplicationServer: as).
	aBoolean
		ifFalse: [ as trafficManagement routingContexts do: [:rc |
				rc routingKeys do: [ :rK | newAS addRoutingKey: rK forRoutingContextId: rc routingContextId ] ] ].

	"configuration SG"
	sgConfiguration := M3UASGConfiguration onServerGateway: sg.
	sg remoteApplicationServers
		do: [ :anAs | 
			anAs registeredAsps
				do: [ :anAsp | sgConfiguration addRemoteTargetPeer: anAsp forSGP: spg ] ].

	"SG process registering and start networkService"
	sg registerSGP: spg.

	"start the network service"
	networkServiceSG m3uaConnectionsServer
		start: self portServerGatewayOne
]

{ #category : #configuration }
M3UAApplicationServerProcessTest >> initServerGatewayOne [
	"The server gateway owns one ASP only for this example.
	Return an Array"

	| networkServiceSG serverGateway1 spg1 |
	networkServiceSG := M3UANetworkServiceOsmoDirectServer new.
	networkServiceSG
		hostname: 'localhost'
		port: self portServerGatewayOne.
	serverGateway1 := M3UAServerGateway name: 'SG1'.
	spg1 := M3UAServerGatewayProcess
		name: serverGateway1 name , '/aspSG'
		identifier: #(10 20 30 40).
	spg1 initWith: networkServiceSG.
	^ Array with: serverGateway1 with: spg1
]

{ #category : #access }
M3UAApplicationServerProcessTest >> notifyMessage [
	| tagStatus |
	tagStatus := M3UATagMGMTNotifyStatus
		type: M3UATagMGMTNotifyStatus typeApplicationServerStateChange
		info: M3UATagMGMTNotifyStatus infoAsActive.
	^ M3UANotifyMessage newMessage
		addTag: tagStatus;
		addTag: (M3UATagINFOString fromString: 'NOTIFY message !');
		yourself
]

{ #category : #configuration }
M3UAApplicationServerProcessTest >> portServerGatewayOne [
	^ 2905
]

{ #category : #configuration }
M3UAApplicationServerProcessTest >> routingKeysForStaticRegistrationForAS: anAS [
	^ self class
		routingKeysWithTrafficModeType: anAS trafficModeType
]

{ #category : #running }
M3UAApplicationServerProcessTest >> tearDown [ 
	super tearDown.
	as ifNotNil: [as registeredAsps do: [:asp | asp networkService ifNotNil: [ asp networkService stop ]]].
	sg ifNotNil: [sg registeredSgps do: [:sgp | sgp networkService ifNotNil: [ sgp networkService stop ]]].
	Smalltalk garbageCollect

]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testASPToSGMock_ScenarioRFC4666Paragraph5111_DirectConnection [
	"Exemple issued from RFC 4666, Paragraph 5.1.1.1
	Point to Point example (one route from AS to SG)"
	

	| asp sgp tagInfoString payload payloadData |
	
	"Server gateway process and application server process"
	self initForDirectConnectionAndNumberOfASPForAS: 1 withDynamicRegistration: false.
	asp := as registeredAsps first.
	sgp := sg registeredSgps first.
	as layerManagement manageASP: asp.

	"SGP start listening incoming connections"		
	sgp networkService start.
	
	sg putDebugOn.
	sgp putDebugOn.
	as putDebugOn.
	asp putDebugOn.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	
	"ASP UP => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	as layerManagement startASP: asp.
	
	self waitSmallDelay.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.
	self assert: sgp lastMsgReceived class equals: M3UAASPUpMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPUpAckMessage.
	
	self waitSmallDelay.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is INACTIVE'.

	"ASP ACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspActive.
	self waitSmallDelay.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.
	self assert: as asStateMachine state class equals: M3UAAsStateActive.
	self assert: sgp lastMsgReceived class equals: M3UAASPActiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPActiveAckMessage.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is ACTIVE'.
	
	"sgp send a MTPTransfer message => test signalUnitData performed"
	payload := self class m3uaAspAcAckFrame.
	payloadData := self createFakePayloadDataWith: payload opc: 61 dpc: 20 routingContextId: 29384 logicalProcess: sgp.
	sg layerManagement receivesTransfer: payloadData forLogicalProcess: asp.
	
	self waitSmallDelay.
	self assert: asp lastMsgReceived class equals: M3UAPayloadDataMessage.
	self assert: as lastPayloadReceived equals: payload.

	"ASP INACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspInactive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.

	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UAASPInactiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPInactiveAckMessage.
		
	"wait recover time is over without any state machine modification"
	(Delay forSeconds: as asStateMachine recoveryTimerDelayMax) wait.
	self waitBigDelay.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.

	"ASP DOWN => ASP and AS state machines will be updated"
	asp aspDown.
	
	self waitSmallDelay.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	self assert: as asStateMachine state class equals: M3UAAsStateDown.
	self assert: sgp lastMsgReceived class equals: M3UAASPDownMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPDownAckMessage.
	
	asp sctpRelease
]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testASPToSGMock_ScenarioRFC4666Paragraph5111_DirectConnection_DynamicRegistration [
	"Exemple issued from RFC 4666, Paragraph 5.1.1.2
	Point to Point example (one route from AS to SG)"
	

	| asp tagInfoString payload routingKeys registrationRequestMsg sgp tagsRC deregistrationRequestMsg remoteAS payloadData |
	
	"Server gateway process and application server process"
	self initForDirectConnectionAndNumberOfASPForAS: 1 withDynamicRegistration: true.
	asp := as registeredAsps first.
	sgp := sg registeredSgps first.
	as layerManagement manageASP: asp.

	"SGP start listening incoming connections"		
	sgp networkService start.
	
	sg putDebugOn.
	sgp putDebugOn.
	as putDebugOn.
	asp putDebugOn.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	
	"ASP UP => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	as layerManagement startASP: asp.
	
	self waitSmallDelay.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.
	self assert: sgp lastMsgReceived class equals: M3UAASPUpMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPUpAckMessage.
	
	self waitSmallDelay.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is INACTIVE'.
	tagsRC := as lastNotifyMessageReceived findAllTags: M3UAConstants tagRoutingContext.
	self assert: tagsRC size equals: 0.
	remoteAS := sg remoteApplicationServers first.
	self assert: remoteAS handledRoutingContextsIds size equals: 0.

	"registration"
	routingKeys := self routingKeysForStaticRegistrationForAS: asp.
	registrationRequestMsg := as layerManagement rkReg: asp with: routingKeys.
	asp sendMessage: registrationRequestMsg toPeer: sgp.
	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UARegistrationRequestMessage.
	self assert: remoteAS handledRoutingContextsIds size equals: 2.
	self waitSmallDelay.
	self assert: asp lastMsgReceived class equals: M3UARegistrationResponseMessage.
	self waitSmallDelay.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagsRC := as lastNotifyMessageReceived findAllTags: M3UAConstants tagRoutingContext.
	self assert: tagsRC size equals: 2.
	self waitSmallDelay.

	"dergistration of one RC"
	deregistrationRequestMsg := as layerManagement rkDereg: asp with: (OrderedCollection with: routingKeys first routingContextId).
	asp sendMessage: deregistrationRequestMsg toPeer: sgp.
	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UADeregistrationRequestMessage.
	self assert: remoteAS handledRoutingContextsIds size equals: 1.
	self waitSmallDelay.
	self assert: asp lastMsgReceived class equals: M3UADeregistrationResponseMessage.
	self waitSmallDelay.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagsRC := as lastNotifyMessageReceived findAllTags: M3UAConstants tagRoutingContext.
	self assert: tagsRC size equals: 1.
	self waitSmallDelay.
		
	"ASP ACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspActive.
	self waitSmallDelay.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.
	self assert: as asStateMachine state class equals: M3UAAsStateActive.
	self assert: sgp lastMsgReceived class equals: M3UAASPActiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPActiveAckMessage.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is ACTIVE'.
	
	"SPG send a MTPTransfer message => test signalUnitData performed"
	payload := self class m3uaAspAcAckFrame.
	payloadData := self createFakePayloadDataWith: payload opc: 61 dpc: 20 routingContextId: 29384 logicalProcess: sgp.
	sg layerManagement receivesTransfer: payloadData forLogicalProcess: asp.
	
	self waitSmallDelay.
	self assert: asp lastMsgReceived class equals: M3UAPayloadDataMessage.
	self assert: as lastPayloadReceived equals: payload.
	

	"ASP INACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspInactive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.

	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UAASPInactiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPInactiveAckMessage.
		
	"wait recover time is over without any state machine modification"
	(Delay forSeconds: as asStateMachine recoveryTimerDelayMax) wait.
	(Delay forSeconds: 1) wait.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.

	"ASP DOWN => ASP and AS state machines will be updated"
	asp aspDown.
	
	self waitSmallDelay.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	self assert: as asStateMachine state class equals: M3UAAsStateDown.
	self assert: sgp lastMsgReceived class equals: M3UAASPDownMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPDownAckMessage.
	
	asp sctpRelease
]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testASPToSGMock_ScenarioRFC4666Paragraph5111_DirectConnection_and_SSNM_messages [
	"Exemple issued from RFC 4666, Paragraph 5.1.1.1
	Point to Point example (one route from AS to SG)"
	

	| asp sgp payload daudMessage payloadData |
	
	"Server gateway process and application server process"
	self initForDirectConnectionAndNumberOfASPForAS: 1 withDynamicRegistration: false.
	asp := as registeredAsps first.
	sgp := sg registeredSgps first.
	as layerManagement manageASP: asp.

	"SGP start listening incoming connections"		
	sgp networkService start.
	
	sg putDebugOn.
	sgp putDebugOn.
	as putDebugOn.
	asp putDebugOn.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	
	"ASP UP => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	as layerManagement startASP: asp.
	
	self waitSmallDelay.
	asp aspActive.
	self waitSmallDelay.
		
	"sgp send a MTPTransfer message => test signalUnitData performed"
	Transcript cr; logCr: '********** SGP sends a PAYLOAD to ASP'.
	payload := self class m3uaAspAcAckFrame.
	payloadData := self createFakePayloadDataWith: payload opc: 55555 dpc: 11111 routingContextId: 12345 logicalProcess: sg registeredSgps first.
	sg layerManagement receivesTransfer: payloadData forLogicalProcess: asp.
	
	self waitSmallDelay.
	self assert: asp lastMsgReceived class equals: M3UAPayloadDataMessage.
	self assert: as lastPayloadReceived equals: payload.

	"asp send a MTPTransfer message, with an unknown destination (dpc=66666)"
	self waitBigDelay.
	Transcript cr; logCr: '********** ASP sends a PAYLOAD to SGP with an UNKNOWN DESTINATION'.
	payloadData := self createFakePayloadDataWith: payload opc: 55555 dpc: 66666 routingContextId: 12345 logicalProcess: asp.
	as layerManagement receivesTransfer: payloadData forLogicalProcess: sgp.
	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UAPayloadDataMessage.
	self should: [sg lastPayloadReceived] raise: Error.
	self assert: asp lastMsgReceived class equals: M3UADestinationUnavailableMessage.
	self assert: (as trafficManagement unavailableDestinations includes: 66666).
	self assert: (as trafficManagement unavailableRoutingContexts includes: as handledRoutingContexts first).
	(Delay forSeconds: asp resendingDAUDPeriod) wait.
	self assert: sgp lastMsgReceived class equals: M3UADestinationStateAuditMessage.
	
	"clear mock"
	asp disableDAUDScheduler.
	self waitBigDelay.
	as trafficManagement removeDestination: 66666.
	asp resetLastMsgReceived.
	sg removeDestination: 66666.

	"asp send a MTPTransfer message, with an known destination (dpc=11111)"
	Transcript cr; logCr: '********** ASP sends a PAYLOAD to SGP with a KNOWN DESTINATION'.
	payloadData := self createFakePayloadDataWith: payload opc: 55555 dpc: 11111 routingContextId: 12345 logicalProcess: asp.
	as layerManagement receivesTransfer: payloadData forLogicalProcess: sgp.
	self waitSmallDelay.
	self assert: asp lastMsgReceived isNil.
	self assert: as trafficManagement unavailableDestinations isEmpty.
	self assert: as trafficManagement unavailableRoutingContexts isEmpty.
	
	"asp send an Destination State Audit message - all is OK, should receive a DAVA"
	self waitBigDelay.
	sg availableDestination: 11111.
	self assert: (sg remoteApplicationServers first trafficManagement isDestinationAvailable: 11111 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)).
	Transcript cr; logCr: '********** ASP sends a DAUD (should receive DAVA)'.
	daudMessage := as auditMessageForDestinations: (OrderedCollection with: 11111) routingContextsIds: (OrderedCollection with: 12345).
	asp sendMessage: daudMessage toPeer: sgp. 
	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UADestinationStateAuditMessage.
	self assert: asp lastMsgReceived class equals: M3UADestinationAvailableMessage.
	
	"asp send an Destination State Audit message - should receive a DUPU"
	asp enableDAUDScheduler.
	self waitBigDelay.
	sg userPartSCCPUnavailableDestination: 11111.
	self assert: (sg remoteApplicationServers first trafficManagement isDestinationUserPartUnavailable: 11111 mtp3User: 3 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)).
	Transcript cr; logCr: '********** ASP sends a DAUD (should receive DUPU)'.
	asp sendMessage: daudMessage toPeer: sgp. 
	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UADestinationStateAuditMessage.
	self assert: asp lastMsgReceived class equals: M3UADestinationUserPartUnavailableMessage.
	self assert: ((asp host trafficManagement destinationPointCodesTrafficManagement userPartUnavailableDestinationsForMTP3User: (M3UADestinationUserPartUnavailableMessage dictionaryMTP3UserIdentity
				at: 'SCCP')) includes: 11111).
	self assert: ((asp host trafficManagement destinationPointCodesTrafficManagement userPartUnavailableDestinationsForMTP3User: (M3UADestinationUserPartUnavailableMessage dictionaryMTP3UserIdentity
				at: 'ISUP')) includes: 11111) not.
	self assert: (as trafficManagement isDestinationUserPartUnavailable: 11111 mtp3User: 3 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)).

	"asp send an Destination State Audit message - should receive a DRST"
	self waitBigDelay.
	sg restrictedDestination: 11111.
	self assert: (sg remoteApplicationServers first trafficManagement isDestinationRestricted: 11111 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)).
	self assert: (as trafficManagement isDestinationRestricted: 11111 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)) not.
	Transcript cr; logCr: '********** ASP sends a DAUD (should receive DRST)'.
	asp sendMessage: daudMessage toPeer: sgp. 
	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UADestinationStateAuditMessage.
	self assert: asp lastMsgReceived class equals: M3UADestinationRestrictedMessage.
	self assert: (asp host trafficManagement destinationPointCodesTrafficManagement restrictedDestinations includes: 11111).
	self assert: (as trafficManagement isDestinationRestricted: 11111 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)).

	"asp send an Destination State Audit message - should receive a SCON"
	self waitBigDelay.
	sg congestedDestination: 11111.
	self assert: (sg remoteApplicationServers first trafficManagement isExistingCongestionForDestination: 11111 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)).
	self assert: (as trafficManagement isExistingCongestionForDestination: 11111 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)) not.	
	Transcript cr; logCr: '********** ASP sends a DAUD (should receive SCON)'.
	asp sendMessage: daudMessage toPeer: sgp. 
	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UADestinationStateAuditMessage.
	self assert: asp lastMsgReceived class equals: M3UASignallingCongestionMessage.
	self assert: (asp host trafficManagement destinationPointCodesTrafficManagement congestedDestinations includes: 11111).
	self assert: (as trafficManagement isExistingCongestionForDestination: 11111 networkAppearance: 777 routingContextsIds: (OrderedCollection with: 12345)).
	
	"clear mock"
	self waitBigDelay.
	asp resetLastMsgReceived.
	"set destination 11111 unavailable"
	sg unavailableDestination: 11111.

	"asp send a MTPTransfer message to the unavailable destination (dpc=11111)"
	Transcript cr; logCr: '********** ASP sends a PAYLOAD to SGP with an UNAVAILABLE DESTINATION'.
	payloadData := self createFakePayloadDataWith: payload opc: 55555 dpc: 11111 routingContextId: 12345 logicalProcess: asp.
	as layerManagement receivesTransfer: payloadData forLogicalProcess: sgp.
	self waitSmallDelay.
	self assert: asp lastMsgReceived class equals: M3UADestinationUnavailableMessage.
	self assert: (as trafficManagement unavailableDestinations includes: 11111).
	self assert: (as trafficManagement unavailableRoutingContextsIds includes: 12345).
	"a DAUD timer must has been set and messages sent periodically"
	(Delay forSeconds: asp resendingDAUDPeriod) wait.
	self assert: sgp lastMsgReceived class equals: M3UADestinationStateAuditMessage.
	(Delay forSeconds: asp resendingDAUDPeriod) wait.
	self assert: sgp lastMsgReceived class equals: M3UADestinationStateAuditMessage.
	
	"set destination 11111 available again"
	Transcript cr; logCr: '********** SET DESTINATION AVAILABLE AGAIN'.
	sg availableDestination: 11111.
	(Delay forSeconds: asp resendingDAUDPeriod) wait.
	self assert: asp lastMsgReceived class equals: M3UADestinationAvailableMessage.
	self assert: (as trafficManagement unavailableDestinations isEmpty).
	self assert: (as trafficManagement unavailableRoutingContexts isEmpty).
	
	"ASP INACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspInactive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.

	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UAASPInactiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPInactiveAckMessage.
		
	"wait recover time is over without any state machine modification"
	(Delay forSeconds: as asStateMachine recoveryTimerDelayMax) wait.
	(Delay forSeconds: 1) wait.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.

	"ASP DOWN => ASP and AS state machines will be updated"
	asp aspDown.
	
	self waitSmallDelay.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	self assert: as asStateMachine state class equals: M3UAAsStateDown.
	self assert: sgp lastMsgReceived class equals: M3UAASPDownMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPDownAckMessage.
	
	asp sctpRelease
]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testASPToSGMock_ScenarioRFC4666Paragraph5111_DirectConnection_variant1 [
	"This the same example as testASPToSGMock_ScenarioRFC4666Paragraph5111_DirectConnection, excepted that :
	- ASP sends only one Routing Context to SG
	- ASP sends an ACTIVE message again after the INACTIVE one, before the recovery time has expired
	- ASP sends DOWN message after that the AS was in AS-ACTIVE state (instead of AS-INACTIVE state in the other case)"
	

	| asp sgp tagInfoString payload tagsRCs rcs payloadData |
	
	"Server gateway process and application server process"
	self initForDirectConnectionAndNumberOfASPForAS: 1 withDynamicRegistration: false.
	asp := as registeredAsps first.
	sgp := sg registeredSgps first.
	as layerManagement manageASP: asp.

	"SGP start listening incoming connections"		
	sgp networkService start.
	
	sg putDebugOn.
	sgp putDebugOn.
	as putDebugOn.
	asp putDebugOn.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	
	"ASP UP => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	as layerManagement startASP: asp.
	
	self waitSmallDelay.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.
	self assert: sgp lastMsgReceived class equals: M3UAASPUpMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPUpAckMessage.
	
	self waitSmallDelay.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is INACTIVE'.

	self assert: (sg isRoutingContextActive: 12345) equals: false.
	self assert: (sg isRoutingContextActive: 67890) equals: false.

	"ASP ACTIVE for ONLY ONE routingContext => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspActiveWithRoutingContextsIds: (OrderedCollection with: as handledRoutingContextsIds first).
	self waitSmallDelay.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.
	self assert: as asStateMachine state class equals: M3UAAsStateActive.
	self assert: sgp lastMsgReceived class equals: M3UAASPActiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPActiveAckMessage.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is ACTIVE'.
	self assert: (sg isRoutingContextActive: as handledRoutingContextsIds first) equals: true.
	self assert: (sg isRoutingContextActive: as handledRoutingContextsIds last) equals: false.
	tagsRCs := (asp lastMsgReceived findAllTags: M3UAConstants tagRoutingContext).
	rcs := tagsRCs collect: [ :tag | tag data asInteger ].
	self assert: rcs size equals: 1.
	self assert: rcs first equals: as handledRoutingContextsIds first.
	
	"sgp send a MTPTransfer message => test signalUnitData performed"
	payload := self class m3uaAspAcAckFrame.
	payloadData := self createFakePayloadDataWith: payload opc: 61 dpc: 20 routingContextId: 29384 logicalProcess: sgp.
	sg layerManagement receivesTransfer: payloadData forLogicalProcess: asp.
	
	self waitSmallDelay.
	self assert: asp lastMsgReceived class equals: M3UAPayloadDataMessage.
	self assert: as lastPayloadReceived equals: payload.
	

	"ASP INACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspInactive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.

	self waitSmallDelay.
	self assert: sgp lastMsgReceived class equals: M3UAASPInactiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPInactiveAckMessage.
		
	"ASP ACTIVE sent after 2 sec (before the recover time has expired)"
	(Delay forSeconds: 2) wait.
	asp aspActive.
	self waitSmallDelay.
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.
	self assert: as asStateMachine state class equals: M3UAAsStateActive.
	self assert: sgp lastMsgReceived class equals: M3UAASPActiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPActiveAckMessage.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.

	"ASP DOWN => ASP and AS state machines will be updated"
	asp aspDown.
	
	self waitSmallDelay.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.
	self assert: sgp lastMsgReceived class equals: M3UAASPDownMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPDownAckMessage.
	
	"wait recover time is over without any state machine modification"
	(Delay forSeconds: as asStateMachine recoveryTimerDelayMax) wait.
	self waitBigDelay.
	self assert: as asStateMachine state class equals: M3UAAsStateDown.

	asp sctpRelease
]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testTansferMessageCreation [
	|  payloadMsg readPayloadMsg routingContextTag protocolDataTag payload networkAppearanceTag correlationIdTag payloadData |
	payload := self class m3uaAspAcAckFrame.
	payloadData := self createFakePayloadDataWith: payload.
	payloadMsg := M3UAApplicationServer new createTransferMessageWithPayloadData: payloadData.
	readPayloadMsg := M3UAMSG
		parseToClassFromStream: payloadMsg asByteArray.
	self assert: readPayloadMsg class equals: M3UAPayloadDataMessage.
	self
		assert: (networkAppearanceTag := readPayloadMsg tags first) class
		equals: M3UATagNetworkAppearance.
	self assert: networkAppearanceTag data asInteger equals: 777.
	self
		assert: (routingContextTag := readPayloadMsg findTag: M3UAConstants tagRoutingContext) class
		equals: M3UATagRoutingContext.
	self assert: routingContextTag data asInteger equals: 29384.
	self
		assert: (protocolDataTag := readPayloadMsg findTag: M3UAConstants tagProtocolData) class
		equals: M3UATagProtocolData.
	self assert: protocolDataTag opcField equals: 61.
	self assert: protocolDataTag dpcField equals: 20.
	self assert: protocolDataTag siField equals: 3.
	self assert: protocolDataTag niField equals: 3.
	self assert: protocolDataTag mpField equals: 0.
	self assert: protocolDataTag slsField equals: 9.
	self
		assert: protocolDataTag userProtocolData
		equals: self class m3uaAspAcAckFrame.
	self
		assert: (correlationIdTag := readPayloadMsg tags last) class
		equals: M3UATagCorrelationID.
	self assert: correlationIdTag data asInteger equals: 28.

]

{ #category : #private }
M3UAApplicationServerProcessTest >> waitBigDelay [
	| delay |
	delay := 3.
	(Delay forSeconds: delay) wait
]

{ #category : #private }
M3UAApplicationServerProcessTest >> waitSmallDelay [
	| delay |
	delay := 200.
	(Delay forMilliseconds: delay) wait
]
