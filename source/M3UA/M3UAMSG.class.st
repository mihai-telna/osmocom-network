"
I can parse a M3UA message from the wire, allow you
    to see the class, type and include tags. In C the structure will
    look like this:

struct m3ua_common_hdr {
	uint8_t version;
	uint8_t spare;
	uint8_t msg_class;
	uint8_t msg_type;
	uint32_t msg_length;
	uint8_t data[0];
} __attribute__((packed));


struct m3ua_parameter_hdr {
	uint16_t tag;
	uint16_t len;
	uint8_t data[0];
} __attribute__((packed));
	
"
Class {
	#name : #M3UAMSG,
	#superclass : #Object,
	#instVars : [
		'msg_class',
		'msg_type',
		'tags',
		'originAspIdentifier',
		'serverChannel'
	],
	#category : #'M3UA-Messages'
}

{ #category : #parsing }
M3UAMSG class >> copyFromOtherMessage: aMsg [
	^ self new
		msgClass: aMsg msgClass;
		msgType: aMsg msgType;
		tags: aMsg tags;
		yourself
]

{ #category : #parsing }
M3UAMSG class >> fromClass: aClass type: aType [
	^ self new
		instVarNamed: #msg_class put: aClass;
		instVarNamed: #msg_type put: aType;
		yourself
]

{ #category : #creation }
M3UAMSG class >> messageClass [
	^ self subclassResponsibility
]

{ #category : #creation }
M3UAMSG class >> messageTag [
	^ self subclassResponsibility
]

{ #category : #creation }
M3UAMSG class >> newMessage [
	^ self new
		msgClass: self messageClass;
		msgType: self messageTag;
		yourself
]

{ #category : #parsing }
M3UAMSG class >> parseFrom: aMsg [
	self logDataContext: aMsg area: #m3ua.
	^ self new
		parseFrom: aMsg readStream;
		yourself
]

{ #category : #parsing }
M3UAMSG class >> parseToClassFromStream: aStream [
	"This will attempt to parse the message into one of the
	 available subclasses."

	| rawMsg msgClasses |
	rawMsg := self parseFrom: aStream.

	"A simple class based lookup"
	msgClasses := {M3UAASPSMMessage.
	M3UAASPTMMessage.
	M3UAMGMTMessage.
	M3UARKMMessage.
	M3UASSNMMessage.
	M3UATransferMessage}.
	msgClasses
		do: [ :msgClass | 
			rawMsg msgClass = msgClass messageClass
				ifTrue: [ msgClass
						allSubclassesDo: [ :class | 
							class messageTag = rawMsg msgType
								ifTrue: [ ^ class copyFromOtherMessage: rawMsg ] ] ] ].
	^ self
		error:
			('Unknown message class (<1p>) or message type (<2p>)'
				expandMacrosWith: rawMsg msgClass
				with: rawMsg msgType)
]

{ #category : #encoding }
M3UAMSG >> addTag: aTag [
	self tags add: aTag
]

{ #category : #converting }
M3UAMSG >> asByteArray [
	| buffer |
	buffer := MessageBuffer new.
	self writeOn: buffer.
	^ buffer asByteArray
]

{ #category : #creation }
M3UAMSG >> class: aClass [
	msg_class := aClass
]

{ #category : #'m3ua-asp-dispatch' }
M3UAMSG >> dispatchOnAsp: anAsp [
	anAsp handleUnknownMessage: self
]

{ #category : #accessing }
M3UAMSG >> findAllTags: aTagIdentifier [
	^ self tags collect: [ :each | each isTag: aTagIdentifier ]
]

{ #category : #accessing }
M3UAMSG >> findTag: aTagIdentifier [
	"I find a tag with a tag identifier"

	^ self findTag: aTagIdentifier ifAbsent: [ nil ]
]

{ #category : #accessing }
M3UAMSG >> findTag: aTagIdentifier ifAbsent: aBlock [
	"I find a tag with a tag identifier"

	self tags
		do: [ :each | 
			(each isTag: aTagIdentifier)
				ifTrue: [ ^ each ] ].
	^ aBlock value
]

{ #category : #accessing }
M3UAMSG >> msgClass [
	^ msg_class
]

{ #category : #creation }
M3UAMSG >> msgClass: aClass [
	self class: aClass
]

{ #category : #accessing }
M3UAMSG >> msgType [
	^ msg_type
]

{ #category : #creation }
M3UAMSG >> msgType: aType [
	msg_type := aType
]

{ #category : #accessing }
M3UAMSG >> originAspIdentifier [
	^ originAspIdentifier
]

{ #category : #accessing }
M3UAMSG >> originAspIdentifier: anObject [
	originAspIdentifier := anObject
]

{ #category : #parsing }
M3UAMSG >> parseFrom: aStream [
	| len |
	self parseVersion: aStream.
	self parseSpare: aStream.
	msg_class := aStream next.
	msg_type := aStream next.
	len := self parseLength: aStream.
	tags := self parseTags: aStream to: aStream position + len - 8
]

{ #category : #parsing }
M3UAMSG >> parseLength: aStream [
	| len |
	len := ((aStream next: 4) uintAt: 1) swap32.
	aStream size - aStream position < (len - 8)
		ifTrue: [ self
				logError:
					('M3UA length is not plausible <1p> <2p>.'
						expandMacrosWith: len
						with: aStream size - aStream position)
				area: #m3ua.
			self
				error:
					('M3UA length is not plausible <1p> <2p>.'
						expandMacrosWith: len
						with: aStream size - aStream position) ].
	^ len
]

{ #category : #parsing }
M3UAMSG >> parseSpare: aStream [
	| spare |
	spare := aStream next.
	spare = M3UAConstants spare
		ifFalse: [ self
				logError: ('M3UA spare is wrong <1p>.' expandMacrosWith: spare)
				area: #m3ua.
			self error: ('M3UA spare is wrong <1p>.' expandMacrosWith: spare) ]
]

{ #category : #parsing }
M3UAMSG >> parseTags: aStream to: end [
	tags := OrderedCollection new.
	[ aStream position < end ]
		whileTrue: [ tags add: (M3UATag parseToClassFromStream: aStream) ].
	^ tags
]

{ #category : #parsing }
M3UAMSG >> parseVersion: aStream [
	| version |
	version := aStream next.
	version = M3UAConstants version
		ifFalse: [ self
				logError: ('M3UA version is wrong <1p>.' expandMacrosWith: version)
				area: #m3ua.
			self
				error: ('M3UA version is wrong <1p>.' expandMacrosWith: version) ]
]

{ #category : #accessing }
M3UAMSG >> serverChannel [
	^ serverChannel
]

{ #category : #accessing }
M3UAMSG >> serverChannel: anObject [
	serverChannel := anObject
]

{ #category : #private }
M3UAMSG >> tags [
	^ tags ifNil: [ tags := OrderedCollection new ]
]

{ #category : #creation }
M3UAMSG >> tags: aTags [
	tags := aTags
]

{ #category : #private }
M3UAMSG >> writeOn: aMsg [
	| tag_data |
	tag_data := MessageBuffer new.

	"Create the tag data"
	self tags do: [ :each | each writeOn: tag_data ].
	aMsg putByte: M3UAConstants version.
	aMsg putByte: M3UAConstants spare.
	aMsg putByte: msg_class.
	aMsg putByte: msg_type.
	aMsg putLen32: tag_data size + 8.
	aMsg putByteArray: tag_data
]
