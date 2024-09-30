Class {
	#name : #M3UALogicalEntity,
	#superclass : #M3UAEntity,
	#instVars : [
		'name',
		'registeredProcesses',
		'pointCode',
		'configuration',
		'lastNotifyMessageReceived',
		'lastErrorMessageReceived'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
M3UALogicalEntity class >> name: aString [
	^ self new
		name: aString;
		yourself
]

{ #category : #'handling-messages-ASP' }
M3UALogicalEntity >> canRespondToProcess: anApplicationServerProcess [
	self flag: #todo.
	^ anApplicationServerProcess notNil
]

{ #category : #'process searching' }
M3UALogicalEntity >> chooseProcess [
	^ self subclassResponsibility
]

{ #category : #accessing }
M3UALogicalEntity >> configuration [
	^ configuration
]

{ #category : #accessing }
M3UALogicalEntity >> configuration: anObject [
	configuration := anObject
]

{ #category : #sending }
M3UALogicalEntity >> createErrorMessageCode: anInteger [
	^ M3UAErrorMessage newMessage
		addTag: (M3UATagMGMTErrorCode initWithData: anInteger asByteArray);
		yourself
]

{ #category : #miscellaneous }
M3UALogicalEntity >> errorCodeFror: aString [
	| dico |
	
	"=> class var + method"
	self flag: #todo.
	
	dico := Dictionary new.
	dico at: 'Invalid Version' put: '01'.
	dico at: 'Not Used in M3UA' put: '02'.
	dico at: 'Unsupported Message Class' put: '03'.
	dico at: 'Unsupported Message Type' put: '04'.
	dico at: 'Unsupported Traffic Mode Type' put: '05'.
	dico at: 'Unexpected Message' put: '06'.
	dico at: 'Protocol Error' put: '07'.
	dico at: 'Not Used in M3UA' put: '08'.
	dico at: 'Invalid Stream Identifier' put: '09'.
	dico at: 'Not Used in M3UA' put: '0a'.
	dico at: 'Not Used in M3UA' put: '0b'.
	dico at: 'Not Used in M3UA' put: '0c'.
	dico at: 'Refused - Management Blocking' put: '0d'.
	dico at: 'ASP Identifier Required' put: '0e'.
	dico at: 'Invalid ASP Identifier' put: '0f'.
	dico at: 'Not Used in M3UA' put: '10'.
	dico at: 'Invalid Parameter Value' put: '11'.
	dico at: 'Parameter Field Error' put: '12'.
	dico at: 'Unexpected Parameter' put: '13'.
	dico at: 'Destination Status Unknown' put: '14'.
	dico at: 'Invalid Network Appearance' put: '15'.
	dico at: 'Missing Parameter' put: '16'.
	dico at: 'Not Used in M3UA' put: '17'.
	dico at: 'Not Used in M3UA' put: '18'.
	dico at: 'Invalid Routing Context' put: '19'.
	dico at: 'No Configured AS for ASP' put: '1a'.
	^ ByteArray
		readHexFrom: (dico at: aString ifAbsent: [ '18' ]) asInteger
]

{ #category : #'process searching' }
M3UALogicalEntity >> findProcessWithIdentifier: aByteArray [
	"We are looking for an ASP/SGP within our own registered ASPs/DGPs"

	registeredProcesses
		do: [ :aspOrSgp | 
			aspOrSgp identifier = aByteArray asArray
				ifTrue: [ ^ aspOrSgp ] ]
]

{ #category : #initialization }
M3UALogicalEntity >> initialize [ 
	super initialize.
	registeredProcesses := OrderedCollection new.
	name := ''
]

{ #category : #accessing }
M3UALogicalEntity >> lastErrorMessageReceived [
	^ lastErrorMessageReceived
]

{ #category : #accessing }
M3UALogicalEntity >> lastNotifyMessageReceived [
	^ lastNotifyMessageReceived
]

{ #category : #debug }
M3UALogicalEntity >> logDebug: aString [
	self logDebug: self name , ' : ' , aString area: #m3ua
]

{ #category : #accessing }
M3UALogicalEntity >> name [
	^ name
]

{ #category : #accessing }
M3UALogicalEntity >> name: anObject [
	name := anObject
]

{ #category : #'messages creation' }
M3UALogicalEntity >> notifyMessageStatus: anIntegerStatus identifier: aByteArray routingContext: anIntegerRC string: aString [
	| msg |
	msg := M3UANotifyMessage newMessage.
	msg
		addTag:
			(M3UATagMGMTNotifyStatus
				type: M3UATagMGMTNotifyStatus statusApplicationServerStateChange
				info: anIntegerStatus).
	aByteArray
		ifNotNil: [ msg addTag: (M3UATagASPIdentifier new data: aByteArray) ].
	anIntegerRC
		ifNotNil: [ msg addTag: (M3UATagRoutingContext initWithInteger32: anIntegerRC) ].
	msg addTag: (M3UATagINFOString new data: aString asByteArray).
	^ msg
]

{ #category : #accessing }
M3UALogicalEntity >> pointCode [
	^ pointCode
]

{ #category : #accessing }
M3UALogicalEntity >> pointCode: anObject [
	pointCode := anObject
]

{ #category : #miscellaneous }
M3UALogicalEntity >> receiveErrorMessage: aMsgError [
	"I have received an error message forworded by one of my ASP"
	
	lastErrorMessageReceived := aMsgError
]

{ #category : #miscellaneous }
M3UALogicalEntity >> receiveNotifyMessage: aMsgNotify [
	"I have received a notify message forworded by one of my ASP"
	
	lastNotifyMessageReceived := aMsgNotify
]
