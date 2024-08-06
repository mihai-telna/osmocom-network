Class {
	#name : #OsmoMessageServerM3UA,
	#superclass : #OsmoMessageServer,
	#instVars : [
		'networkService',
		'dicoDelegates'
	],
	#category : #'M3UA-Communication'
}

{ #category : #initialization }
OsmoMessageServerM3UA >> acceptOneConnection [
	| client conn socketStream delegate s6aService |
	client := socket waitForAcceptFor: 60.
	client ifNil: [ ^ self ].

	"--- debug ---"
	"--- end debug ---"

	socketStream := (SocketStream on: client)
		binary;
		noTimeout;
		yourself.
	conn := socketClass new
		errorDelegate: self;
		socket: socketStream;
		yourself.
	delegate := OsmoMessageReadDelegateM3UA new
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

{ #category : #adding }
OsmoMessageServerM3UA >> addDelegates: aCollectionOfOsmoMessageReadDelegateM3UA forAsp: anAsp [
	dicoDelegates at: anAsp put: aCollectionOfOsmoMessageReadDelegateM3UA
]

{ #category : #accessing }
OsmoMessageServerM3UA >> dicoDelegates [
	^ dicoDelegates
]

{ #category : #accessing }
OsmoMessageServerM3UA >> dicoDelegates: anObject [
	dicoDelegates := anObject
]

{ #category : #initialization }
OsmoMessageServerM3UA >> initialize [
	super initialize.
	dicoDelegates := Dictionary new
]

{ #category : #accessing }
OsmoMessageServerM3UA >> networkService [
	^ networkService
]

{ #category : #accessing }
OsmoMessageServerM3UA >> networkService: anObject [
	networkService := anObject
]
