Class {
	#name : #M3UAApplicationServerProcessTest,
	#superclass : #TestCase,
	#instVars : [
		'sg',
		'as'
	],
	#category : #'M3UA-Tests'
}

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
	| rc1 rc2 routingKey1 routingKey2 |
	rc1 := 12345.
	rc2 := 67890.
	
	routingKey1 := M3UARoutingKey dpc: 11111.
	routingKey1 localRKIdentifier: 1.
	routingKey1 listOpc: (OrderedCollection with: 33333 with: 44444).
	routingKey1 routingContext: rc1.
	routingKey1 trafficModeType: anInteger.
	routingKey1 serviceIndicators: #(12 34).
	routingKey1 networkAppearance: 777.
	
	routingKey2 := M3UARoutingKey dpc: 22222.
	routingKey2 localRKIdentifier: 2.
	routingKey2 listOpc: (OrderedCollection with: 55555 with: 66666).
	routingKey2 routingContext: rc2.
	routingKey2 trafficModeType: anInteger.
	routingKey2 serviceIndicators: #(45 56).
	routingKey2 networkAppearance: 888.
	
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
				do: [ :rK | as addRoutingKey: rK forRoutingContext: rK routingContext ] ].
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
		ifFalse: [ as dictRoutingContextRoutingKey
				keysAndValuesDo: [ :rc :rK | newAS addRoutingKey: rK forRoutingContext: rc ] ].

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
		type: M3UATagMGMTNotifyStatus statusApplicationServerStateChange
		info: M3UATagMGMTNotifyStatus infoAsActive.
	^ M3UANotifyMessage newMessage
		addTag: tagStatus;
		addTag: (M3UATagINFOString new data: 'NOTIFY masg !' asByteArray);
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
	as registeredAsps do: [:asp | asp networkService ifNotNil: [ asp networkService stop ]].
	sg registeredSgps do: [:sgp | sgp networkService ifNotNil: [ sgp networkService stop ]].
	Smalltalk garbageCollect

]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testASPToSGMock_ScenarioRFC4666Paragraph5111_DirectConnection [
	"Exemple issued from RFC 4666, Paragraph 5.1.1.1
	Point to Point example (one route from AS to SG)"
	

	| delay asp layerManagement sgp payloadMsg tagInfoString payload |
	delay := 200.
	
	"Server gateway process and application server process"
	self initForDirectConnectionAndNumberOfASPForAS: 1 withDynamicRegistration: false.
	asp := as registeredAsps first.
	sgp := sg registeredSgps first.

	"Create a Layer Managements (LM)"
	layerManagement := M3UALayerManagement onManagedASP: asp.

	"SGP start listening incoming connections"		
	sgp networkService start.
	
	sg putDebugOn.
	sgp putDebugOn.
	as putDebugOn.
	asp putDebugOn.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	
	"ASP UP => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	layerManagement startASP: asp.
	
	(Delay forMilliseconds: delay) wait.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.
	self assert: sgp lastMsgReceived class equals: M3UAASPUpMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPUpAckMessage.
	
	(Delay forMilliseconds: delay) wait.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is INACTIVE'.

	"ASP ACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspActive.
	(Delay forMilliseconds: delay) wait.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.
	self assert: as asStateMachine state class equals: M3UAAsStateActive.
	self assert: sgp lastMsgReceived class equals: M3UAASPActiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPActiveAckMessage.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is ACTIVE'.
	
	"sgp send a MTPTransfer message => test signalUnitData performed"
	payloadMsg := sgp
		createMTPTransferRequestPrimitiveWithData: (payload := self class m3uaAspAcAckFrame)
		routingContext: 29
		opc: 61
		dpc: 20
		si: 3
		ni: 3
		mp: 0
		sls: 9.
	sgp sendMessage: payloadMsg toPeer: as registeredAsps first. 
	
	(Delay forMilliseconds: delay) wait.
	self assert: asp lastMsgReceived class equals: M3UAPayloadDataMessage.
	self assert: as lastPayloadReceived equals: payload.
	

	"ASP INACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspInactive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.

	(Delay forMilliseconds: delay) wait.
	self assert: sgp lastMsgReceived class equals: M3UAASPInactiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPInactiveAckMessage.
		
	"wait recover time is over without any state machine modification"
	(Delay forSeconds: as asStateMachine recoveryTimerDelayMax) wait.
	(Delay forSeconds: 1) wait.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.

	"ASP DOWN => ASP and AS state machines will be updated"
	asp aspDown.
	
	(Delay forMilliseconds: delay) wait.
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
	

	| delay asp layerManagement payloadMsg tagInfoString payload routingKeys registrationRequestMsg sgp tagsRC deregistrationRequestMsg remoteAS |
	delay := 200.
	
	"Server gateway process and application server process"
	self initForDirectConnectionAndNumberOfASPForAS: 1 withDynamicRegistration: true.
	asp := as registeredAsps first.
	sgp := sg registeredSgps first.

	"Create a Layer Managements (LM)"
	layerManagement := M3UALayerManagement onManagedASP: asp.

	"SGP start listening incoming connections"		
	sgp networkService start.
	
	sg putDebugOn.
	sgp putDebugOn.
	as putDebugOn.
	asp putDebugOn.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	
	"ASP UP => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	layerManagement startASP: asp.
	
	(Delay forMilliseconds: delay) wait.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.
	self assert: sgp lastMsgReceived class equals: M3UAASPUpMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPUpAckMessage.
	
	(Delay forMilliseconds: delay) wait.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is INACTIVE'.
	tagsRC := as lastNotifyMessageReceived findAllTags: M3UAConstants tagRoutingContext.
	self assert: tagsRC size equals: 0.
	remoteAS := sg remoteApplicationServers first.
	self assert: remoteAS handledRoutingContexts size equals: 0.

	"registration"
	routingKeys := self routingKeysForStaticRegistrationForAS: asp.
	registrationRequestMsg := layerManagement rkReg: asp with: routingKeys.
	asp sendMessage: registrationRequestMsg toPeer: sgp.
	(Delay forMilliseconds: delay) wait.
	self assert: sgp lastMsgReceived class equals: M3UARegistrationRequestMessage.
	self assert: remoteAS handledRoutingContexts size equals: 2.
	(Delay forMilliseconds: delay) wait.
	self assert: asp lastMsgReceived class equals: M3UARegistrationResponseMessage.
	(Delay forMilliseconds: delay) wait.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagsRC := as lastNotifyMessageReceived findAllTags: M3UAConstants tagRoutingContext.
	self assert: tagsRC size equals: 2.
	(Delay forMilliseconds: delay) wait.

	"dergistration of one RC"
	deregistrationRequestMsg := layerManagement rkDereg: asp with: (OrderedCollection with: routingKeys first routingContext).
	asp sendMessage: deregistrationRequestMsg toPeer: sgp.
	(Delay forMilliseconds: delay) wait.
	self assert: sgp lastMsgReceived class equals: M3UADeregistrationRequestMessage.
	self assert: remoteAS handledRoutingContexts size equals: 1.
	(Delay forMilliseconds: delay) wait.
	self assert: asp lastMsgReceived class equals: M3UADeregistrationResponseMessage.
	(Delay forMilliseconds: delay) wait.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagsRC := as lastNotifyMessageReceived findAllTags: M3UAConstants tagRoutingContext.
	self assert: tagsRC size equals: 1.
	(Delay forMilliseconds: delay) wait.
		
	"ASP ACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspActive.
	(Delay forMilliseconds: delay) wait.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.
	self assert: as asStateMachine state class equals: M3UAAsStateActive.
	self assert: sgp lastMsgReceived class equals: M3UAASPActiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPActiveAckMessage.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is ACTIVE'.
	
	"SPG send a MTPTransfer message => test signalUnitData performed"
	payloadMsg := sgp
		createMTPTransferRequestPrimitiveWithData: (payload := self class m3uaAspAcAckFrame)
		routingContext: 29
		opc: 61
		dpc: 20
		si: 3
		ni: 3
		mp: 0
		sls: 9.
	sgp sendMessage: payloadMsg toPeer: as registeredAsps first. 
	
	(Delay forMilliseconds: delay) wait.
	self assert: asp lastMsgReceived class equals: M3UAPayloadDataMessage.
	self assert: as lastPayloadReceived equals: payload.
	

	"ASP INACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspInactive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.

	(Delay forMilliseconds: delay) wait.
	self assert: sgp lastMsgReceived class equals: M3UAASPInactiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPInactiveAckMessage.
		
	"wait recover time is over without any state machine modification"
	(Delay forSeconds: as asStateMachine recoveryTimerDelayMax) wait.
	(Delay forSeconds: 1) wait.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.

	"ASP DOWN => ASP and AS state machines will be updated"
	asp aspDown.
	
	(Delay forMilliseconds: delay) wait.
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
	

	| delay asp layerManagement sgp payloadMsg tagInfoString payload tagsRCs rcs |
	delay := 200.
	
	"Server gateway process and application server process"
	self initForDirectConnectionAndNumberOfASPForAS: 1 withDynamicRegistration: false.
	asp := as registeredAsps first.
	sgp := sg registeredSgps first.

	"Create a Layer Managements (LM)"
	layerManagement := M3UALayerManagement onManagedASP: asp.

	"SGP start listening incoming connections"		
	sgp networkService start.
	
	sg putDebugOn.
	sgp putDebugOn.
	as putDebugOn.
	asp putDebugOn.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	
	"ASP UP => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	layerManagement startASP: asp.
	
	(Delay forMilliseconds: delay) wait.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStateInactive.
	self assert: sgp lastMsgReceived class equals: M3UAASPUpMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPUpAckMessage.
	
	(Delay forMilliseconds: delay) wait.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is INACTIVE'.

	self assert: (sg dictRoutingContextActivities at: 12345) equals: false.
	self assert: (sg dictRoutingContextActivities at: 67890) equals: false.

	"ASP ACTIVE for ONLY ONE routingContext => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspActiveWithRoutingContexts: (OrderedCollection with: as handledRoutingContexts first).
	(Delay forMilliseconds: delay) wait.
	
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.
	self assert: as asStateMachine state class equals: M3UAAsStateActive.
	self assert: sgp lastMsgReceived class equals: M3UAASPActiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPActiveAckMessage.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.
	tagInfoString := as lastNotifyMessageReceived findTag: M3UAConstants tagINFOString.
	self assert: tagInfoString data asString equals: 'NOTIFY : ASP AS 1/ASP1 is ACTIVE'.
	self assert: (sg dictRoutingContextActivities at: as handledRoutingContexts first) equals: true.
	self assert: (sg dictRoutingContextActivities at: as handledRoutingContexts last) equals: false.
	tagsRCs := (asp lastMsgReceived findAllTags: M3UAConstants tagRoutingContext).
	rcs := tagsRCs collect: [ :tag | tag data asInteger ].
	self assert: rcs size equals: 1.
	self assert: rcs first equals: as handledRoutingContexts first.
	
	"sgp send a MTPTransfer message => test signalUnitData performed"
	payloadMsg := sgp
		createMTPTransferRequestPrimitiveWithData: (payload := self class m3uaAspAcAckFrame)
		routingContext: 29
		opc: 61
		dpc: 20
		si: 3
		ni: 3
		mp: 0
		sls: 9.
	sgp sendMessage: payloadMsg toPeer: as registeredAsps first. 
	
	(Delay forMilliseconds: delay) wait.
	self assert: asp lastMsgReceived class equals: M3UAPayloadDataMessage.
	self assert: as lastPayloadReceived equals: payload.
	

	"ASP INACTIVE => SG will ACK and send a NOTIFY message, ASP and AS state machines will be updated"
	asp aspInactive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.

	(Delay forMilliseconds: delay) wait.
	self assert: sgp lastMsgReceived class equals: M3UAASPInactiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPInactiveAckMessage.
		
	"ASP ACTIVE sent after 2 sec (before the recover time has expired)"
	(Delay forSeconds: 2) wait.
	asp aspActive.
	(Delay forMilliseconds: delay) wait.
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.
	self assert: as asStateMachine state class equals: M3UAAsStateActive.
	self assert: sgp lastMsgReceived class equals: M3UAASPActiveMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPActiveAckMessage.
	self assert: as lastNotifyMessageReceived class equals: M3UANotifyMessage.

	"ASP DOWN => ASP and AS state machines will be updated"
	asp aspDown.
	
	(Delay forMilliseconds: delay) wait.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	self assert: as asStateMachine state class equals: M3UAAsStatePending.
	self assert: sgp lastMsgReceived class equals: M3UAASPDownMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPDownAckMessage.
	
	"wait recover time is over without any state machine modification"
	(Delay forSeconds: as asStateMachine recoveryTimerDelayMax) wait.
	(Delay forSeconds: 1) wait.
	self assert: as asStateMachine state class equals: M3UAAsStateDown.

	asp sctpRelease
]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testTansferMessageCreation [
	| asp payloadMsg readPayloadMsg routingContextTag protocolDataTag |
	asp := M3UAApplicationServerProcess name: 'asp' identifier: nil.
	payloadMsg := asp
		createMTPTransferRequestPrimitiveWithData: self class m3uaAspAcAckFrame
		routingContext: 29
		opc: 61
		dpc: 20
		si: 3
		ni: 3
		mp: 0
		sls: 9.
	readPayloadMsg := M3UAMSG
		parseToClassFromStream: payloadMsg asByteArray.
	self assert: readPayloadMsg class equals: M3UAPayloadDataMessage.
	self
		assert: (routingContextTag := readPayloadMsg tags first) class
		equals: M3UATagRoutingContext.
	self assert: routingContextTag data asInteger equals: 29.
	self
		assert: (protocolDataTag := readPayloadMsg tags last) class
		equals: M3UATagProtocolData.
	self assert: protocolDataTag opcField equals: 61.
	self assert: protocolDataTag dpcField equals: 20.
	self assert: protocolDataTag siField equals: 3.
	self assert: protocolDataTag niField equals: 3.
	self assert: protocolDataTag mpField equals: 0.
	self assert: protocolDataTag slsField equals: 9.
	self
		assert: protocolDataTag userProtocolData
		equals: self class m3uaAspAcAckFrame
]
