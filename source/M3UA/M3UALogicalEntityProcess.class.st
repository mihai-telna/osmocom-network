Class {
	#name : #M3UALogicalEntityProcess,
	#superclass : #M3UAEntity,
	#instVars : [
		'host',
		'name',
		'identifier',
		'networkService',
		'lastMsgReceived',
		'mtp3Boundary'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
M3UALogicalEntityProcess class >> name: aString identifier: anArray [
	^ self new
		name: aString;
		identifier: anArray;
		yourself
]

{ #category : #tags }
M3UALogicalEntityProcess >> createInfoTag [
	^ M3UATagINFOString fromString: 'Hello from Smalltalk'
]

{ #category : #'error handling' }
M3UALogicalEntityProcess >> handleChannelClosedForDelegate: aM3UAOsmoMessageReadDelegate [
	self logDebug: ' Channel ', aM3UAOsmoMessageReadDelegate channelNumber printString, ' closed'
]

{ #category : #handling }
M3UALogicalEntityProcess >> handleMessageReceived: aM3UAMessage [
	"We have received a message from the network service,
	and we knows from which delegate it comes from.
	We can store this message associated to the incoming channel, in order to send a response back if necessary
	"

	"debug"

	self logDebug: '#handleMessageReceived:  ' , aM3UAMessage class name.
	"end debug"
	(aM3UAMessage class = M3UANotifyMessage
		or: [ aM3UAMessage class = M3UAErrorMessage ])
		ifFalse: [ lastMsgReceived := aM3UAMessage ].
	aM3UAMessage dispatchOnLogicalProcess: self
]

{ #category : #handling }
M3UALogicalEntityProcess >> handleUnknownMessage: aMsg [
	"We got something we don't know. ignore it for now."

	
]

{ #category : #accessing }
M3UALogicalEntityProcess >> host [
	^ host
]

{ #category : #accessing }
M3UALogicalEntityProcess >> host: aM3UASGOrAS [
	host := aM3UASGOrAS
]

{ #category : #accessing }
M3UALogicalEntityProcess >> identifier [
	^ identifier
]

{ #category : #accessing }
M3UALogicalEntityProcess >> identifier: anObject [
	identifier := anObject
]

{ #category : #initialization }
M3UALogicalEntityProcess >> initWith: aNetworkService [
	self networkService: aNetworkService.
	aNetworkService logicalProcess: self
]

{ #category : #initialization }
M3UALogicalEntityProcess >> initialize [
	super initialize.
	mtp3Boundary := M3UAMTP3Boundary new
]

{ #category : #accessing }
M3UALogicalEntityProcess >> lastMsgReceived [
	^ lastMsgReceived
]

{ #category : #debug }
M3UALogicalEntityProcess >> logDebug: aString [
	self logDebug: self name , ' : ' , aString area: #m3ua
]

{ #category : #accessing }
M3UALogicalEntityProcess >> mtp3Boundary [
	^ mtp3Boundary
]

{ #category : #accessing }
M3UALogicalEntityProcess >> name [
	^ name
]

{ #category : #accessing }
M3UALogicalEntityProcess >> name: anObject [
	name := anObject
]

{ #category : #access }
M3UALogicalEntityProcess >> networkService [
	^ networkService
]

{ #category : #access }
M3UALogicalEntityProcess >> networkService: aService [
	networkService := aService.
	networkService
		onSctpConnect: [ self sctpConnected ];
		onSctpRelease: [ self sctpReleased ]
]

{ #category : #debug }
M3UALogicalEntityProcess >> putDebug: aBoolean [
	super putDebug: aBoolean.
	networkService ifNotNil: [networkService putDebug: aBoolean]
]

{ #category : #sending }
M3UALogicalEntityProcess >> sendAckMessage: aMessageACK inReplyToMessage: aReceivedMessage [
	networkService sendReplyMessage: aMessageACK inReplyToMessage: aReceivedMessage
]

{ #category : #sending }
M3UALogicalEntityProcess >> sendMessage: aM3UAMessage toPeer: aM3UALogicalEntityProcess [
	"Use this method for sending messages which don't expect a ACK in reply"

	"debug"
	self
		logDebug:
			'(#sendMessage::toPeer:) ' , aM3UAMessage class name , ' from '
				, self name , ' to ' , aM3UALogicalEntityProcess name.
	"end debug"
	
	networkService
		send: aM3UAMessage
		from: self
		toTargetPeer: aM3UALogicalEntityProcess
]
