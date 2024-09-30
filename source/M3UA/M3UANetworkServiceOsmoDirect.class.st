Class {
	#name : #M3UANetworkServiceOsmoDirect,
	#superclass : #M3UNetworkServiceAOsmoBase,
	#instVars : [
		'delegate'
	],
	#category : #'M3UA-Communication'
}

{ #category : #accessing }
M3UANetworkServiceOsmoDirect >> delegate [
	^ delegate
]

{ #category : #accessing }
M3UANetworkServiceOsmoDirect >> delegate: anObject [
	delegate := anObject
]

{ #category : #access }
M3UANetworkServiceOsmoDirect >> delegateForASP: anApplicationServerProcess targetPeerIdentifier: anArray [
	^ delegate
]

{ #category : #transport }
M3UANetworkServiceOsmoDirect >> delegateForChannel: anInteger [
	^ delegate
]

{ #category : #transport }
M3UANetworkServiceOsmoDirect >> delegateForMessage: aM3UAMessage [
	^ delegate
]

{ #category : #dispatching }
M3UANetworkServiceOsmoDirect >> doReceiveM3uaMessage: aByteArray delegate: aM3UAReadDelegate [
	| msg |
	[ msg := M3UAMSG parseToClassFromStream: aByteArray ]
		on: Error
		do:
			[ :err | ^ self m3uaHandler handledError: #malformedMessage forMessage: nil ].

	"Server case :
	If the delegate is associated to a server for the M3UA transaction, 
	we affect a delegate's index to the message in order to recognize who was the sender 
	(in case we have to send a potential answer further)"
	msg logicalProcessReceiver: self logicalProcess.
	msg delegateChannel: aM3UAReadDelegate channelNumber.

	"Forward the message to the ASP"
	self logicalProcess handleMessageReceived: msg
]

{ #category : #dispatching }
M3UANetworkServiceOsmoDirect >> doRecvM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA [
	"ModuleBoundary
		runSynchronous: [" LogDataPayload value: aByteArray.
			self
				doReceiveM3uaMessage: aByteArray
				delegate: aOsmoMessageReadDelegateM3UA "]"
]

{ #category : #internal }
M3UANetworkServiceOsmoDirect >> doSend: aMessage to: aToPoc from: aFromPoc [
	delegate nextPut: aMessage with: IPAConstants protocolSCCP
]

{ #category : #internal }
M3UANetworkServiceOsmoDirect >> initialize [
	super initialize.
		
	"delegate"
	delegate := M3UAOsmoMessageReadDelegate new
		m3uaConnection: self;
		yourself.
	
	"connection"
	conn := OsmoMessageDirectConnection new.
	conn readDelegate: delegate.
		
	delegate
		onConnect: [ :handler :dispatcher | handler registerApplicationM3uaOn: dispatcher  ]
]

{ #category : #access }
M3UANetworkServiceOsmoDirect >> m3uaHandler [
	| handlerBlock |
	handlerBlock := delegate dispatcher handlers
		at: M3UAConstants applicationM3UA
		ifAbsent: [ ^ nil ].
	^ handlerBlock at: 2
]

{ #category : #transport }
M3UANetworkServiceOsmoDirect >> myHandlerForMessage: aM3UAMessage [
	"For One channel only (one delegate only)"

	^ aM3UAMessage myHandlerForDelegate: delegate
]

{ #category : #sending }
M3UANetworkServiceOsmoDirect >> send: aMessage from: anApplicationServerProcess toTargetPeer: aRemoteASP [
	| myDelegate handler |
	"debug"
	self
		logDebug:
			'(#send:from:toTargetPeer:) ' , aMessage class name , ' from '
				, anApplicationServerProcess name , ' to ' , aRemoteASP name.
	"end debug"
	
	(myDelegate := self
		delegateForASP: anApplicationServerProcess
		targetPeerIdentifier: aRemoteASP identifier) ifNil: [ ^ self ].
		
	"debug"
	self
		logDebug: '(#send:from:toTargetPeer:) delegate : ' , myDelegate channelNumber printString.
	"end debug"
	
	(handler := myDelegate handlerForM3UAMessage: aMessage)
		ifNil: [ ^ self ].

	"debug"
	self logDebug: '(#send:from:toTargetPeer:) Message sent'.
	"end debug"
	
	handler sendMessage: aMessage
]

{ #category : #sending }
M3UANetworkServiceOsmoDirect >> send: aMessage onChannel: anInteger [
	| myDelegate handler |
	
	aMessage ifNil: [ ^ self ].
	
	"debug"
	self logDebug: '#send:onChannel: ' , aMessage class name, ' channel ', anInteger printString.
	"end debug"

	(myDelegate := self delegateForChannel: anInteger)
		ifNil: [ ^ self ].
	(handler := myDelegate handlerForM3UAMessage: aMessage)
		ifNil: [ ^ self ].
		
	"debug"
	self logDebug: ' Message sent on channel ', anInteger printString.
	"end debug"

	handler sendMessage: aMessage
]

{ #category : #'messages handling' }
M3UANetworkServiceOsmoDirect >> sendMessage: aM3UAMessage withHandler: aHandler [
	aHandler sendMessage: aM3UAMessage
]

{ #category : #sending }
M3UANetworkServiceOsmoDirect >> sendReplyMessage: aReplyMessage inReplyToMessage: aReceivedMessage [
	"We have to write in the socket corresponding to the chanel that has received the incoming message"

	| ws handler |
	delegate := self delegateForMessage: aReceivedMessage.

	"debug"
	ws := WriteStream on: (String new: 200).
	ws
		nextPutAll: ' sends a ';
		nextPutAll: aReplyMessage class name;
		nextPutAll: ' through channel '.
	delegate channelNumber printOn: ws.
	aReceivedMessage aspIdentifier
		ifNotNil: [ :array | 
			ws
				nextPutAll: ' to the remote ASP with identifier ';
				nextPutAll: array printString ].
	self logDebug: ws contents.
	"end debug"
	
	handler := delegate handlerForM3UAMessage: aReplyMessage.
	handler sendMessage: aReplyMessage
]

{ #category : #connect }
M3UANetworkServiceOsmoDirect >> stop [
	delegate ifNotNil: [ delegate stop ].
	super stop
]
