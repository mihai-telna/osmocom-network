Class {
	#name : #M3UNetworkServiceAOsmoBase,
	#superclass : #M3UANetworkService,
	#instVars : [
		'conn',
		'rxCounter'
	],
	#category : #'M3UA-Communication'
}

{ #category : #access }
M3UNetworkServiceAOsmoBase >> delegateForASP: anApplicationServerProcess targetPeerIdentifier: anArray [
	^ self subclassResponsibility
]

{ #category : #dispatching }
M3UNetworkServiceAOsmoBase >> doRecvM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA [
	^ self subclassResponsibility
]

{ #category : #access }
M3UNetworkServiceAOsmoBase >> hostname [
	^ conn hostname
]

{ #category : #initialization }
M3UNetworkServiceAOsmoBase >> hostname: aHostname port: aPort [
	conn
		hostname: aHostname;
		port: aPort
]

{ #category : #initialization }
M3UNetworkServiceAOsmoBase >> initialize [
	super initialize.
	rxCounter := 0
]

{ #category : #access }
M3UNetworkServiceAOsmoBase >> port [
	^ conn port
]

{ #category : #dispatching }
M3UNetworkServiceAOsmoBase >> receiveM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA [

	"This atomicity is not guaranteed"
	rxCounter := rxCounter + 1.
	
	"--- debug ---"
	self logDebug: '#receiveM3uaMessage:delegate:'.
	"--- end debug ---"
	
	"do the job"
	self doRecvM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA
]

{ #category : #connect }
M3UNetworkServiceAOsmoBase >> start [
	conn start.
	super start
]

{ #category : #connect }
M3UNetworkServiceAOsmoBase >> stop [
	conn ifNotNil: [ conn stop ]
]
