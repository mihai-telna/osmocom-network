Class {
	#name : #M3UAOsmoMessageServer,
	#superclass : #OsmoMessageServer,
	#instVars : [
		'networkService',
		'dicoDelegates'
	],
	#category : #'M3UA-Communication'
}

{ #category : #initialization }
M3UAOsmoMessageServer >> acceptOneConnection [
	| client conn socketStream delegate |
	client := socket waitForAcceptFor: 60.
	client ifNil: [ ^ self ].

	"--- debug ---"
	self logDebug: '#acceptOneConnection'.
	"--- end debug ---"

	socketStream := (SocketStream on: client)
		binary;
		noTimeout;
		yourself.
	conn := socketClass new
		errorDelegate: self;
		socket: socketStream;
		yourself.
	delegate := M3UAOsmoMessageReadDelegate new
		m3uaConnection: networkService;
		yourself.
	delegate
		onConnect:
			[ :handler :dispatcher | handler registerApplicationM3uaOn: dispatcher ].
	[ conn readDelegate: delegate.
	delegate onNewConnection: conn.
	self addDelegate: delegate.
	self addClientConnection: conn.
	conn startHandling ]
		ifCurtailed: [ self removeAndTerminateConnection: conn ]
]

{ #category : #initialization }
M3UAOsmoMessageServer >> addDelegate: aDelegate [
	| number |
	dicoDelegates
		at: (number := dicoDelegates keys size + 1)
		put: aDelegate.
	aDelegate channelNumber: number
]

{ #category : #access }
M3UAOsmoMessageServer >> delegateForChannel: anInteger [
	^ dicoDelegates at: anInteger ifAbsent: [ nil ]
]

{ #category : #accessing }
M3UAOsmoMessageServer >> dicoDelegates [
	^ dicoDelegates
]

{ #category : #initialization }
M3UAOsmoMessageServer >> initialize [
	super initialize.
	dicoDelegates := Dictionary new
]

{ #category : #debug }
M3UAOsmoMessageServer >> logDebug: aString [
	networkService
		logDebug: self class name , '(' , networkService logicalProcess name , ') : ' , aString
		area: #m3ua
]

{ #category : #accessing }
M3UAOsmoMessageServer >> networkService [
	^ networkService
]

{ #category : #accessing }
M3UAOsmoMessageServer >> networkService: anObject [
	networkService := anObject
]
