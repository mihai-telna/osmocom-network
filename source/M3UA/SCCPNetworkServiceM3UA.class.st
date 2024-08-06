Class {
	#name : #SCCPNetworkServiceM3UA,
	#superclass : #SCCPNetworkService,
	#instVars : [
		'applicationServer',
		'on_connect_block',
		'on_release_block'
	],
	#category : #'M3UA-Communication'
}

{ #category : #'instance creation' }
SCCPNetworkServiceM3UA class >> on: anM3UAApplicationServer [
	^ self new
		as: anM3UAApplicationServer;
		yourself
]

{ #category : #accessing }
SCCPNetworkServiceM3UA >> applicationServer [
	^ applicationServer
]

{ #category : #accessing }
SCCPNetworkServiceM3UA >> applicationServer: anAs [
	applicationServer := anAs
]

{ #category : #'data messages handling' }
SCCPNetworkServiceM3UA >> handleSCCPData: aByteArray fromOpc: anIntegerOPC toDpc: anIntegerDPC priority: anIntegerMP [
	self halt.
]

{ #category : #sctp }
SCCPNetworkServiceM3UA >> onSctpConnect: aBlock [
	on_connect_block := aBlock
]

{ #category : #sctp }
SCCPNetworkServiceM3UA >> onSctpRelease: aBlock [
	on_release_block := aBlock
]

{ #category : #dispatch }
SCCPNetworkServiceM3UA >> send: aMsg toRemoteAsp: aRemoteAsp [
	"We have to write in the socket corresponding to the chanel with the remote ASP"

	self send: aMsg remoteAspIdentifier: aRemoteAsp identifier.
	
	self flag: #temporarly.
	aRemoteAsp networkService signalUnitData: aMsg fromAS: applicationServer to: aRemoteAsp.
	aRemoteAsp lastMsgReceived: aMsg
]

{ #category : #dispatch }
SCCPNetworkServiceM3UA >> sendToPeer: aMsg from: anApplicationServerProcess [
	| remotePeerIdentifier peer |
	(remotePeerIdentifier := applicationServer
		peerIdentifierForAsp: anApplicationServerProcess) ifNil: [ ^ self ].
	peer := applicationServer
		findRemoteAspWithIdentifier: remotePeerIdentifier.
	aMsg originAspIdentifier: anApplicationServerProcess identifier.
	peer
		ifNil: [ self send: aMsg remoteAspIdentifier: remotePeerIdentifier ]
		ifNotNil: [ self send: aMsg toRemoteAsp: peer ]
]

{ #category : #callbacks }
SCCPNetworkServiceM3UA >> signalUnitData: aMsg fromAS: anApplicationServer to: anAsp [
	"Inform the upper layer about data"

	self
		logDebug:
			self class name , ' signalUnitData from the AS '
				, anApplicationServer name , 'to the ASP ' , anAsp name
		area: #m3ua.
	on_data
		ifNotNil: [ on_data
				cull: anApplicationServer name
				cull: anAsp identifier
				cull: 2
				cull: aMsg ]
]

{ #category : #connect }
SCCPNetworkServiceM3UA >> start [
	self
		logDebug: self class name , ' started.'
		area: #m3ua.
	on_connect_block value
]

{ #category : #connect }
SCCPNetworkServiceM3UA >> stop [
	self
		logDebug: self class name , ' stopped.'
		area: #m3ua.
	on_release_block value
]
