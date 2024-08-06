Class {
	#name : #SCCPNetworkServiceM3UAOsmoDirect,
	#superclass : #SCCPNetworkServiceM3UAOsmoBase,
	#instVars : [
		'delegate',
		'peer'
	],
	#category : #'M3UA-Communication'
}

{ #category : #accessing }
SCCPNetworkServiceM3UAOsmoDirect >> delegate [
	^ delegate
]

{ #category : #accessing }
SCCPNetworkServiceM3UAOsmoDirect >> delegate: anObject [
	delegate := anObject
]

{ #category : #dispatching }
SCCPNetworkServiceM3UAOsmoDirect >> doReceiveM3uaMessage: aByteArray delegate: aOsmoMessageDiameterReadDelegate [
	| msg |
	
	[ msg := M3UAMSG parseToClassFromStream: aByteArray ]
		on: Error
		do:
			[ :err | ^ self m3uaHandler handledError: #malformedMessage forMessage: nil ].

	"Server case :
	If the delegate is associated to a server for the Diameter transaction, 
	we affect a delegate's index to the message in order to recognize who was the sender 
	(in case we have to send a potential answer further)"
	aOsmoMessageDiameterReadDelegate numberForServer
		ifNotNil: [ :anInt | msg serverChannel: anInt ].

	"Injects the Diameter Message in the RHDiameterCentral"
	msg m3uaNetworkServiceDispatch: self delegate: aOsmoMessageDiameterReadDelegate
]

{ #category : #dispatching }
SCCPNetworkServiceM3UAOsmoDirect >> doRecvM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA [
	"ModuleBoundary
		runSynchronous: [" LogDataPayload value: aByteArray.
			self
				doReceiveM3uaMessage: aByteArray
				delegate: aOsmoMessageReadDelegateM3UA "]"
]

{ #category : #internal }
SCCPNetworkServiceM3UAOsmoDirect >> doSend: aMessage to: aToPoc from: aFromPoc [
	delegate nextPut: aMessage with: IPAConstants protocolSCCP
]

{ #category : #internal }
SCCPNetworkServiceM3UAOsmoDirect >> initialize [
	super initialize.
		
	"delegate"
	delegate := OsmoMessageReadDelegateM3UA new
		m3uaConnection: self;
		yourself.
	
	"connection"
	conn := OsmoMessageDirectConnection new.
	conn readDelegate: delegate.
		
	delegate
		onConnect: [ :handler :dispatcher | handler registerApplicationM3uaOn: dispatcher  ]
]

{ #category : #access }
SCCPNetworkServiceM3UAOsmoDirect >> m3uaHandler [
	| handlerBlock |
	handlerBlock := delegate dispatcher handlers
		at: M3UAConstants applicationM3UA
		ifAbsent: [ ^ nil ].
	^ handlerBlock at: 2
]

{ #category : #accessing }
SCCPNetworkServiceM3UAOsmoDirect >> peer [
	^ peer
]

{ #category : #accessing }
SCCPNetworkServiceM3UAOsmoDirect >> peer: anObject [
	peer := anObject
]

{ #category : #dispatching }
SCCPNetworkServiceM3UAOsmoDirect >> receiveM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA [

	"This atomicity is not guaranteed"
	rxCounter := rxCounter + 1.
	
	"do the job"
	self doRecvM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA
]

{ #category : #dispatching }
SCCPNetworkServiceM3UAOsmoDirect >> send: aMsg remoteAspIdentifier: aRemoteAspIdentifier [
	"We have to write in the socket corresponding to the chanel with the remote ASP"

	self
		logDebug:
			self class name , ' sends a ', aMsg class name, ' to remoteAsp with identifier '
				, aRemoteAspIdentifier printString
		area: #m3ua.
	delegate write: aMsg
]
