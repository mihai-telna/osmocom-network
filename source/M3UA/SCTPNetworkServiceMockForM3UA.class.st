Class {
	#name : #SCTPNetworkServiceMockForM3UA,
	#superclass : #SCCPNetworkService,
	#instVars : [
		'on_connect',
		'on_released',
		'as',
		'asp',
		'otherService'
	],
	#category : #'M3UA-Tests'
}

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> applicationServer: anAs [
	as := anAs
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> applicationServerProcess: anAsp [
	asp := anAsp
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> connectTo: aService [
	otherService := aService
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> hostname [
	^'localhost'
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> nextPut: aMsg on: anId [
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> onSctpConnect: aBlock [
	on_connect := aBlock
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> onSctpData: aBlock [
	on_data := aBlock
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> onSctpRelease: aBlock [
	on_released := aBlock
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> port [
	^0
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> sendMessage: aMsg from: anApplicationServerProcess [
	otherService signalUnitData: aMsg
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> sendToAsp: aMsg [
	on_data 
	    value: nil
	    value: nil
	    value: 2
	    value: aMsg

]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> sendToPeer: aMsg from: anApplicationServerProcess [
	| peer delegates |
	peer := otherService applicationServer registeredAsps
		detect: [ :remoteAsp | remoteAsp identifier = #(199 255 6 197) ]
		ifNone: [ nil ].
	delegates := otherService m3uaConnectionsServer dicoDelegates
		at: peer.
	(delegates
		detect:
			[ :osmoDelegate | osmoDelegate peerIdentifier = anApplicationServerProcess identifier ]
		ifNone: [ nil ])
		signalUnitData: aMsg
		fromAS: as
		from: anApplicationServerProcess
]

{ #category : #internal }
SCTPNetworkServiceMockForM3UA >> signalUnitData: aMsg fromAS: anApplicationServer to: anAsp [
	"Inform the upper layer about data"

	on_data
		ifNotNil: [ on_data
				cull: anApplicationServer name
				cull: anAsp identifier
				cull: 2
				cull: aMsg toMessage asByteArray ]
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> start [
	on_connect value
]

{ #category : #access }
SCTPNetworkServiceMockForM3UA >> stop [
	on_released value
]
