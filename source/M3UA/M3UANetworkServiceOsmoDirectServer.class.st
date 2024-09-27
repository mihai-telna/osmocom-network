Class {
	#name : #M3UANetworkServiceOsmoDirectServer,
	#superclass : #M3UANetworkServiceOsmoDirect,
	#instVars : [
		'm3uaConnectionsServer',
		'dictionaryChannels'
	],
	#category : #'M3UA-Communication'
}

{ #category : #accessing }
M3UANetworkServiceOsmoDirectServer >> addChannel: anInteger forRemoteAsp: anASP [
	dictionaryChannels at: anASP identifier put: anInteger
]

{ #category : #dispatching }
M3UANetworkServiceOsmoDirectServer >> delegateChannelForPeerIdentifier: anArray [
	^ dictionaryChannels at: anArray ifAbsent: [ nil ]
]

{ #category : #access }
M3UANetworkServiceOsmoDirectServer >> delegateForASP: anApplicationServerProcess targetPeerIdentifier: anArray [
	^ m3uaConnectionsServer
		delegateForChannel: (self delegateChannelForPeerIdentifier: anArray)
]

{ #category : #transport }
M3UANetworkServiceOsmoDirectServer >> delegateForChannel: anInteger [
	^ m3uaConnectionsServer delegateForChannel: anInteger
]

{ #category : #transport }
M3UANetworkServiceOsmoDirectServer >> delegateForMessage: aM3UAMessage [
	^ m3uaConnectionsServer delegateForChannel: aM3UAMessage delegateChannel
]

{ #category : #accessing }
M3UANetworkServiceOsmoDirectServer >> dictionaryChannels [
	^ dictionaryChannels
]

{ #category : #accessing }
M3UANetworkServiceOsmoDirectServer >> dictionaryChannels: anObject [
	dictionaryChannels := anObject
]

{ #category : #initialization }
M3UANetworkServiceOsmoDirectServer >> initialize [
	super initialize.
	m3uaConnectionsServer := M3UAOsmoMessageServer new
		networkService: self;
		yourself.
	dictionaryChannels := Dictionary new
]

{ #category : #accessing }
M3UANetworkServiceOsmoDirectServer >> m3uaConnectionsServer [
	^ m3uaConnectionsServer
]

{ #category : #transport }
M3UANetworkServiceOsmoDirectServer >> myHandlerForMessage: aM3UAMessage [
	^ m3uaConnectionsServer myHandlerForMessage: aM3UAMessage
]

{ #category : #'messages handling' }
M3UANetworkServiceOsmoDirectServer >> sendMessage: aM3UAMessage [
	^ self shouldNotImplement 
]

{ #category : #sending }
M3UANetworkServiceOsmoDirectServer >> sendReplyMessage: aReplyMessage inReplyToMessage: aReceivedMessage [
	super
		sendReplyMessage: aReplyMessage
		inReplyToMessage: aReceivedMessage.
	aReceivedMessage aspIdentifier
		ifNotNil: [ :array | 
			delegate := self delegateForMessage: aReceivedMessage.
			dictionaryChannels at: array put: delegate channelNumber ]
]

{ #category : #connect }
M3UANetworkServiceOsmoDirectServer >> stop [
	m3uaConnectionsServer ifNotNil: [ m3uaConnectionsServer stop ].
	super stop
]
