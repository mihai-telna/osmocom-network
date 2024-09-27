Class {
	#name : #M3UAHandler,
	#superclass : #M3UAEntity,
	#instVars : [
		'm3uaConnection',
		'muxer'
	],
	#category : #'M3UA-Communication'
}

{ #category : #sending }
M3UAHandler >> directSend: aByteArray [
	"Basic sending of encoded messages"

	muxer nextPut: aByteArray
]

{ #category : #dispatching }
M3UAHandler >> handledError: aSymbol forMessage: aM3UAMessage [
	aSymbol = #malformedMessage
		ifTrue: [ ^ self
				logError: 'No M3UMessage could be parsed from the ByteArray received by the delegate'
				area: #m3uaConnection ]
]

{ #category : #debug }
M3UAHandler >> logDebug: aString [
	m3uaConnection
		logDebug: 'Handler(' , m3uaConnection logicalProcess name , ') : ' , aString
		area: #m3ua
]

{ #category : #accessing }
M3UAHandler >> m3uaConnection [
	^ m3uaConnection
]

{ #category : #accessing }
M3UAHandler >> m3uaConnection: anObject [
	m3uaConnection := anObject
]

{ #category : #accessing }
M3UAHandler >> muxer: aM3UAMuxer [
	muxer := aM3UAMuxer

]

{ #category : #dispatching }
M3UAHandler >> receiveM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA [
	"Main Entry for handling M3UA messages"

	"--- debug ---"
	self logDebug: '#receiveM3uaMessage:delegate:'.
	"--- end debug ---"
	
	m3uaConnection
		receiveM3uaMessage: aByteArray
		delegate: aOsmoMessageReadDelegateM3UA
]

{ #category : #registration }
M3UAHandler >> registerApplicationM3uaOn: aM3UADispatcher [
	"Registration process is sent at connexion time.
	Adds the adequate handler to the dispatcher."

	"--- debug ---"
	"--- end debug ---"
	
	aM3UADispatcher
		addHandler: M3UAConstants applicationM3UA
		on: self
		with: #receiveM3uaMessage:delegate:
]

{ #category : #sending }
M3UAHandler >> sendMessage: aM3UAMessage [
	self directSend: aM3UAMessage toMessage asByteArray
]
