"
I represent a tag of a M3UA packet. I hold the
    number of the tag and the data associated with it.
"
Class {
	#name : #M3UATag,
	#superclass : #Object,
	#instVars : [
		'tag_nr',
		'data'
	],
	#category : #'M3UA-Tags'
}

{ #category : #creation }
M3UATag class >> copyFromOtherTag: aTag [
	^ self new
		tag_nr: aTag nr;
		data: aTag data;
		yourself
]

{ #category : #parsing }
M3UATag class >> fromStream: aStream [
	^ self new parseFrom: aStream
]

{ #category : #creation }
M3UATag class >> initWith: aTag data: aData [
	^ self new
		instVarNamed: #tag_nr put: aTag;
		instVarNamed: #data put: aData;
		yourself
]

{ #category : #creation }
M3UATag class >> initWithData32bitsInteger: anInteger [
	^ self new
		tag_nr: self nrValue;
		data: (anInteger asByteArrayOfSize: 4);
		yourself
]

{ #category : #creation }
M3UATag class >> initWithData: aData [
	^ self new
		tag_nr: self nrValue;
		data: aData;
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initWithFourInteger32: anArrayOfInteger [
	| array |
	array := ByteArray new: 16.
	array shortAt: 3 put: (anArrayOfInteger at: 1) bigEndian: true.
	array shortAt: 7 put: (anArrayOfInteger at: 2) bigEndian: true.
	array shortAt: 11 put: (anArrayOfInteger at: 3) bigEndian: true.
	array shortAt: 15 put: (anArrayOfInteger at: 4) bigEndian: true.
	
	"buffer := MessageBuffer new.
	buffer putLen32: (anArrayOfInteger at: 1).
	buffer putLen32: (anArrayOfInteger at: 2).
	buffer putLen32: (anArrayOfInteger at: 3).
	buffer putLen32: (anArrayOfInteger at: 4).
	buffer asByteArray"
	^ self new
		tag_nr: self nrValue;
		data: array;
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initWithInteger32: anInteger [
	^ self initWithData32bitsInteger: anInteger
]

{ #category : #'instance creation' }
M3UATag class >> initWithThreeInteger32: anArrayOfInteger [
	| array |
	array := ByteArray new: 12.
	array shortAt: 3 put: (anArrayOfInteger at: 1) bigEndian: true.
	array shortAt: 7 put: (anArrayOfInteger at: 2) bigEndian: true.
	array shortAt: 11 put: (anArrayOfInteger at: 3) bigEndian: true.
	"buffer := MessageBuffer new.
	buffer putLen32: (anArrayOfInteger at: 1).
	buffer putLen32: (anArrayOfInteger at: 2).
	buffer putLen32: (anArrayOfInteger at: 3).
	buffer asByteArray"
	^ self new
		tag_nr: self nrValue;
		data: array;
		yourself
]

{ #category : #access }
M3UATag class >> nrValue [
	^ 0
]

{ #category : #parsing }
M3UATag class >> parseToClassFromStream: aStream [
	"This will attempt to parse the stream into one of the
	 available subclasses."

	| rawTag |
	rawTag := self fromStream: aStream.
	M3UATag allSubclassesDo: 
		 [ :tagClass | 
			rawTag nr = tagClass nrValue
				ifTrue: [ ^ tagClass copyFromOtherTag: rawTag ] ].
	^ rawTag
]

{ #category : #accessing }
M3UATag >> data [
	^ data ifNil: [ data := ByteArray new ]
]

{ #category : #accessing }
M3UATag >> data: anObject [
	data := anObject
]

{ #category : #initialization }
M3UATag >> initialize [
	super initialize.
	tag_nr := self class nrValue
]

{ #category : #accessing }
M3UATag >> isTag: aNr [
	^ self nr = aNr
]

{ #category : #accessing }
M3UATag >> nr [
	^ tag_nr
]

{ #category : #parsing }
M3UATag >> parseFrom: aStream [
	| len padding |
	tag_nr := ((aStream next: 2) shortAt: 1) swap16.
	len := ((aStream next: 2) shortAt: 1) swap16.
	data := aStream next: len - 4.
	padding := len \\ 4.
	padding > 0
		ifTrue: [ self
				logNotice: ('Going to skip <1p> bytes' expandMacrosWith: 4 - padding)
				area: #m3ua.
			aStream skip: 4 - padding ]
]

{ #category : #accessing }
M3UATag >> tag_nr: anInteger [
	tag_nr := anInteger
]

{ #category : #private }
M3UATag >> writeOn: aMsg [
	| rest |
	aMsg putLen16: tag_nr.
	aMsg putLen16: self data size + 4.
	aMsg putByteArray: self data.
	rest := self data size \\ 4.
	rest > 0
		ifTrue: [ aMsg putByteArray: (ByteArray new: 4 - rest) ]
]
