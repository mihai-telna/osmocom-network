"
Instance variables :

- channelNumber	
	In case of a direct connection 1-1 (using an M3UANetworkServiceOsmoDirect as networkService,
	the channel number is one by default.
	In case of a multiple connection 1-n (using an M3UANetworkServiceOsmoDirectServer as networkService,
	the channel number will be attributed by the network service when accepting the connection.


"
Class {
	#name : #M3UAOsmoMessageReadDelegate,
	#superclass : #OsmoMessageReadDelegate,
	#instVars : [
		'demuxer',
		'muxer',
		'dispatcher',
		'connect_block',
		'm3uaConnection',
		'channelNumber'
	],
	#category : #'M3UA-Communication'
}

{ #category : #accessing }
M3UAOsmoMessageReadDelegate >> channelNumber [
	"In case of a direct connection 1-1 (using an M3UANetworkServiceOsmoDirect as networkService,
	the channel number is one by default.
	In case of a multiple connection 1-n (using an M3UANetworkServiceOsmoDirectServer as networkService,
	the channel number will be attributed by the network service when accepting the connection.
	"

	^ channelNumber ifNil: [ 1 ]
]

{ #category : #accessing }
M3UAOsmoMessageReadDelegate >> channelNumber: anObject [
	channelNumber := anObject
]

{ #category : #accessing }
M3UAOsmoMessageReadDelegate >> dispatcher [
	^ dispatcher
]

{ #category : #dispatching }
M3UAOsmoMessageReadDelegate >> handlerForM3UAMessage: aMessage [
	^ (dispatcher handlers at: M3UAConstants applicationM3UA ifAbsent: [  ^ nil]) at: 2
]

{ #category : #debug }
M3UAOsmoMessageReadDelegate >> logDebug: aString [
	m3uaConnection
		logDebug: 'M3UADelegate(' , m3uaConnection logicalProcess name , ') : ' , aString
		area: #m3ua
]

{ #category : #access }
M3UAOsmoMessageReadDelegate >> logicalProcess [
	^ m3uaConnection logicalProcess
]

{ #category : #accessing }
M3UAOsmoMessageReadDelegate >> m3uaConnection [
	^ m3uaConnection
]

{ #category : #accessing }
M3UAOsmoMessageReadDelegate >> m3uaConnection: anObject [
	m3uaConnection := anObject
]

{ #category : #writing }
M3UAOsmoMessageReadDelegate >> nextPut: aData with: aConstant [
	muxer nextPut: aData "with: aConstant"
]

{ #category : #connect }
M3UAOsmoMessageReadDelegate >> onConnect: aBlock [
	"Call the block when the socket is being connected and the dispatcher
	 is set-up. The callback will have the dispatcher as parameter."

	connect_block := aBlock
]

{ #category : #connect }
M3UAOsmoMessageReadDelegate >> onNewConnection: aSocket [
	| handler |
	super onNewConnection: aSocket.

	"--- debug ---"
	self logDebug: '#onNewConnection:'.
	"--- end debug ---"

	"Initialize the muxer/demuxer"
	demuxer := M3UADemuxer initOn: aSocket.
	muxer := M3UAMuxer initOn: aSocket writeQueue.

	"Initialize the dispatcher and the handler"
	dispatcher := M3UADispatcher new.
	dispatcher initialize.
	handler := M3UAHandler new.
	handler
		m3uaConnection: self m3uaConnection;
		registerApplicationM3uaOn: dispatcher;
		muxer: muxer;
		yourself.
	connect_block
		ifNotNil: [ connect_block value: handler value: dispatcher ]
]

{ #category : #reading }
M3UAOsmoMessageReadDelegate >> readOneMessage: aSocket [
	| msg |
	
	[ msg := demuxer next ]
		on: SubscriptOutOfBounds
		do: [ ^ self logicalProcess handleChannelClosedForDelegate: self ].

	"debug"
	self logDebug: ' #readOneMessage: ' , msg class name.
	"end debug"
	dispatcher dispatch: msg first with: msg second fromDelegate: self
]

{ #category : #connect }
M3UAOsmoMessageReadDelegate >> stop [
	connection ifNotNil: [ connection terminate ]
]

{ #category : #writing }
M3UAOsmoMessageReadDelegate >> write: aM3UAMessage [
	self
		nextPut: aM3UAMessage toMessage asByteArray
		with: M3UAConstants applicationM3UA
]
