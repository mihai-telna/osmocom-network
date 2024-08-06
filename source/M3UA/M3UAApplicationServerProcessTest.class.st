Class {
	#name : #M3UAApplicationServerProcessTest,
	#superclass : #TestCase,
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

{ #category : #'as yet unclassified' }
M3UAApplicationServerProcessTest >> aspUpMessage [
	^ M3UAMSG parseToClassFromStream: self class m3uaAspUpFrame
]

{ #category : #'as yet unclassified' }
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

{ #category : #tests }
M3UAApplicationServerProcessTest >> testASPToSGMock [
	| netwrkServiceMock as asp sg aspMock scpNetworkService layerManagement layerManagementMock |
	netwrkServiceMock := SCTPNetworkServiceMockForM3UA new.
	sg := (M3UASGMock new)
		    networkService: netwrkServiceMock;
		    yourself.
	aspMock := M3UAApplicationServerProcess initWith: netwrkServiceMock.
	aspMock name: 'sg/aspMock'.
	aspMock identifier: #(10 26 31 247).
	netwrkServiceMock
	    applicationServer: sg;
	    applicationServerProcess: aspMock.
	sg asp: aspMock.
	aspMock applicationServer: sg.

	scpNetworkService := SCCPNetworkServiceM3UAOsmoDirectServer new.
	as := (M3UAApplicationServer new)
			 networkService: scpNetworkService;
			 name: 'AS 1';
		    yourself.
	"as addRoutingKey: (M3UARoutingKey dpc: 30) routingContext: 2222."
	asp := M3UAApplicationServerProcess initWith: scpNetworkService.
	asp name: 'as/asp1'.
	asp identifier: #(199 255 6 197).
	scpNetworkService
	    applicationServer: as.
	as registerASP: asp.
	as asStateMachine requiredNumberOfAsps: 1.
	as asStateMachine recoveryTimerDelayMax: 5.

	"Create a Layer Managements (LM)"
	layerManagement := (M3UALayerManagement new)
		    applicationServerProcess: asp;
		    yourself.
		
	asp peersIdentifiers addLast: aspMock identifier.
	scpNetworkService initConnectionsServer.

	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	layerManagement manage.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
		
	layerManagementMock := (M3UALayerManagement new)
		    applicationServerProcess: aspMock;
		    yourself.
	netwrkServiceMock connectTo: scpNetworkService.

	as addRemotePeer: aspMock forAsp: asp.
	
	"This works as the mock will handle this synchronously"
	self assert: aspMock aspStateMachine state class equals: M3UAAspStateDown.
	layerManagementMock manage.
	self assert: aspMock aspStateMachine state class equals: M3UAAspStateInactive.
	
	"ASP sends ACTIVE, aspMock will ACK"
	asp aspActive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateActive.

	aspMock sendToPeer: self notifyMessage.
	
	"ASP sends INACTIVE, aspMock will ACK"
	asp aspInactive.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.

	"ASP sends DOWN, aspMock will ACK"
	asp aspDown.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.

	aspMock sctpRelease.
	asp sctpRelease.
	self assert: aspMock aspStateMachine state class equals: M3UAAspStateDown.

]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testASPToSGMock_ScenarioRFC4666Paragraph5111 [
	| networkServiceSG as asp sg scpNetworkService layerManagement layerManagementSG aspSG |
	networkServiceSG := SCCPNetworkServiceM3UAOsmoDirect new.
	sg := M3UAServerGateway new
		networkService: networkServiceSG;
		yourself.
	aspSG := M3UAApplicationServerProcess initWith: networkServiceSG.
	aspSG name: 'sg/aspSG'.
	aspSG identifier: #(10 26 31 247).
	networkServiceSG applicationServer: sg.
	sg registerASP: aspSG.
	sg
		dicoRoutingContextActivities:
			(Dictionary new
				add: 12345 -> false;
				add: 67890 -> false;
				yourself).

	"AS and ASP"
	scpNetworkService := SCCPNetworkServiceM3UAOsmoDirectServer new.
	as := M3UAApplicationServer new
		networkService: scpNetworkService;
		name: 'AS 1';
		yourself.
	"as addRoutingKey: (M3UARoutingKey dpc: 30) routingContext: 2222."
	asp := M3UAApplicationServerProcess initWith: scpNetworkService.
	asp name: 'as/asp1'.
	asp identifier: #(199 255 6 197).
	asp addRoutingContext: 12345.
	asp addRoutingContext: 67890.
	scpNetworkService applicationServer: as.
	as registerASP: asp.
	as asStateMachine requiredNumberOfAsps: 1.
	as asStateMachine recoveryTimerDelayMax: 5.
	scpNetworkService initConnectionsServer.

	"Create a Layer Managements (LM)"
	layerManagement := M3UALayerManagement new
		applicationServerProcess: asp;
		yourself.
	asp peersIdentifiers addLast: aspSG identifier.
	as addRemotePeer: aspSG forAsp: asp.
	scpNetworkService initConnectionsServer.
	aspSG peersIdentifiers addLast: asp identifier.
	sg addRemotePeer: asp forAsp: aspSG.

	"SG UP"
	sg putDebugOff.
	aspSG putDebugOff.
	as putDebugOff.
	asp putDebugOff.
	
	layerManagementSG := M3UALayerManagement new
		applicationServerProcess: aspSG;
		yourself.
	layerManagementSG putDebugOff.
	layerManagement putDebugOff.
	self
		assert: aspSG aspStateMachine state class
		equals: M3UAAspStateDown.
	layerManagementSG manage.
	self
		assert: aspSG aspStateMachine state class
		equals: M3UAAspStateInactive.
		
	sg putDebugOn.
	aspSG putDebugOn.
	as putDebugOn.
	asp putDebugOn.

	"ASP UP"
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	layerManagement manage.
	self
		assert: asp aspStateMachine state class
		equals: M3UAAspStateInactive.
	self assert: aspSG lastMsgReceived class equals: M3UAASPUpMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPUpAckMessage.

	"ASP sends ACTIVE, aspMock will ACK"
	asp
		aspActiveWithTrafficModeType: asp trafficModeType
		routingContexts: asp handledRoutingContexts.
	self
		assert: asp aspStateMachine state class
		equals: M3UAAspStateActive.
	aspSG sendToPeer: self notifyMessage.

	"ASP sends INACTIVE, aspMock will ACK"
	asp aspInactive.
	self
		assert: asp aspStateMachine state class
		equals: M3UAAspStateInactive.

	"ASP sends DOWN, aspMock will ACK"
	asp aspDown.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	aspSG sctpRelease.
	asp sctpRelease.
	self
		assert: aspSG aspStateMachine state class
		equals: M3UAAspStateDown
]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testASPToSGMock_ScenarioRFC4666Paragraph5112 [
	"Single ASP in an Application Server (1+0 Sparing), Dynamic Registration"

	| networkServiceSG as asp sg scpNetworkService layerManagement layerManagementSG aspSG |
	networkServiceSG := SCCPNetworkServiceM3UAOsmoDirect new.
	sg := M3UAServerGateway new
		networkService: networkServiceSG;
		yourself.
	aspSG := M3UAApplicationServerProcess initWith: networkServiceSG.
	aspSG name: 'sg/aspSG'.
	aspSG identifier: #(10 26 31 247).
	networkServiceSG applicationServer: sg.
	sg registerASP: aspSG.
	sg
		dicoRoutingContextActivities:
			(Dictionary new
				add: 12345 -> false;
				add: 67890 -> false;
				yourself).

	"AS and ASP"
	scpNetworkService := SCCPNetworkServiceM3UAOsmoDirectServer new.
	as := M3UAApplicationServer new
		networkService: scpNetworkService;
		name: 'AS 1';
		yourself.
	"as addRoutingKey: (M3UARoutingKey dpc: 30) routingContext: 2222."
	asp := M3UAApplicationServerProcess initWith: scpNetworkService.
	asp name: 'as/asp1'.
	asp identifier: #(199 255 6 197).
	asp addRoutingContext: 12345.
	asp addRoutingContext: 67890.
	scpNetworkService applicationServer: as.
	as registerASP: asp.
	as asStateMachine requiredNumberOfAsps: 1.
	as asStateMachine recoveryTimerDelayMax: 5.

	"Create a Layer Managements (LM)"
	layerManagement := M3UALayerManagement new
		applicationServerProcess: asp;
		yourself.
	asp peersIdentifiers addLast: aspSG identifier.
	as addRemotePeer: aspSG forAsp: asp.
	scpNetworkService initConnectionsServer.
	aspSG peersIdentifiers addLast: asp identifier.
	sg addRemotePeer: asp forAsp: aspSG.
	networkServiceSG initConnectionsServer.

	"SG UP"
	sg putDebugOff.
	aspSG putDebugOff.
	as putDebugOff.
	asp putDebugOff.
	
	layerManagementSG := M3UALayerManagement new
		applicationServerProcess: aspSG;
		yourself.
	layerManagementSG putDebugOff.
	layerManagement putDebugOff.
	self
		assert: aspSG aspStateMachine state class
		equals: M3UAAspStateDown.
	layerManagementSG manage.
	self
		assert: aspSG aspStateMachine state class
		equals: M3UAAspStateInactive.
		
	sg putDebugOn.
	aspSG putDebugOn.
	as putDebugOn.
	asp putDebugOn.

	"ASP UP"
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	layerManagement manage.
	self
		assert: asp aspStateMachine state class
		equals: M3UAAspStateInactive.
	self assert: aspSG lastMsgReceived class equals: M3UAASPUpMessage.
	self assert: asp lastMsgReceived class equals: M3UAASPUpAckMessage.

	"ASP sends ACTIVE, aspMock will ACK"
	asp
		aspActiveWithTrafficModeType: asp trafficModeType
		routingContexts: asp handledRoutingContexts.
	self
		assert: asp aspStateMachine state class
		equals: M3UAAspStateActive.
	aspSG sendToPeer: self notifyMessage.

	"ASP sends INACTIVE, aspMock will ACK"
	asp aspInactive.
	self
		assert: asp aspStateMachine state class
		equals: M3UAAspStateInactive.

	"ASP sends DOWN, aspMock will ACK"
	asp aspDown.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	aspSG sctpRelease.
	asp sctpRelease.
	self
		assert: aspSG aspStateMachine state class
		equals: M3UAAspStateDown
]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testSGMockToASP [
	| netwrkServiceMock as asp sg aspMock scpNetworkService layerManagement layerManagementMock payloadMsg |
	netwrkServiceMock := SCTPNetworkServiceMockForM3UA new.
	sg := (M3UASGMock new)
		    networkService: netwrkServiceMock;
		    yourself.
	aspMock := M3UAApplicationServerProcess initWith: netwrkServiceMock.
	aspMock name: 'sg/aspMock'.
	aspMock identifier: #(10 26 31 247).
	netwrkServiceMock
	    applicationServer: sg;
	    applicationServerProcess: aspMock.
	sg asp: aspMock.
	aspMock applicationServer: sg.

	scpNetworkService := SCCPNetworkServiceM3UAOsmoDirectServer new.
	as := (M3UAApplicationServer new)
			 networkService: scpNetworkService;
			 name: 'AS 1';
		    yourself.
	"as addRoutingKey: (M3UARoutingKey opc: 10 dpc: 20) routingContext: 1111."
	asp := M3UAApplicationServerProcess initWith: scpNetworkService.
	asp name: 'as/asp1'.
	asp identifier: #(199 255 6 197).
	scpNetworkService
	    applicationServer: as.
	as registerASP: asp.
	as asStateMachine requiredNumberOfAsps: 1.
	as asStateMachine recoveryTimerDelayMax: 5.

	"Create a Layer Managements (LM)"
	layerManagement := (M3UALayerManagement new)
		    applicationServerProcess: asp;
		    yourself.
		
	asp peersIdentifiers addLast: aspMock identifier.
	scpNetworkService initConnectionsServer.

	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.
	layerManagement manage.
	self assert: asp aspStateMachine state class equals: M3UAAspStateInactive.
		
	layerManagementMock := (M3UALayerManagement new)
		    applicationServerProcess: aspMock;
		    yourself.
	netwrkServiceMock connectTo: scpNetworkService.

	as addRemotePeer: aspMock forAsp: asp.
	
	"This works as the mock will handle this synchronously"
	self assert: aspMock aspStateMachine state class equals: M3UAAspStateDown.
	layerManagementMock manage.
	self assert: aspMock aspStateMachine state class equals: M3UAAspStateInactive.
	
	"mock sends ACTIVE, asp will ACK"
	aspMock aspActive.
	self assert: aspMock aspStateMachine state class equals: M3UAAspStateActive.

	asp sendToPeer: self notifyMessage.
	self assert: aspMock applicationServer lastMsgReceived class equals: M3UANotifyMessage.
	
	"send a MTPTransfer message"
	payloadMsg := aspMock
		createMTPTransferRequestPrimitiveWithData: self class m3uaAspAcAckFrame
		routingContext: 29
		opc: 61
		dpc: 20
		si: 3
		ni: 3
		mp: 0
		sls: 9.
	aspMock sendToPeer: payloadMsg. 
	self assert: asp lastMsgReceived class equals: M3UAPayloadDataMessage.
	
	"mock sends INACTIVE, asp will ACK"
	aspMock aspInactive.
	self assert: aspMock aspStateMachine state class equals: M3UAAspStateInactive.

	"mock sends DOWN, asp will ACK"
	aspMock aspDown.
	self assert: aspMock aspStateMachine state class equals: M3UAAspStateDown.

	asp sctpRelease.
	aspMock sctpRelease.
	self assert: asp aspStateMachine state class equals: M3UAAspStateDown.

]

{ #category : #tests }
M3UAApplicationServerProcessTest >> testTansferMessageCreation [
	| asp payloadMsg readPayloadMsg routingContextTag protocolDataTag |
	asp := M3UAApplicationServerProcess
		initWith: SCTPNetworkServiceMockForM3UA new.
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
