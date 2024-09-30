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

{ #category : #'instance creation' }
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

{ #category : #'instance creation' }
M3UATag class >> initDataWithInteger24bits: anInteger paddingFirstWith: aMaskInteger [
	"Padding is 32 bits (4 bytes)"

	| buffer |
	buffer := MessageBuffer new.
	buffer putByteArray: (aMaskInteger asByteArrayOfSize: 1).
	buffer putByteArray: (anInteger asByteArrayOfSize: 3).
	^ self new
		tag_nr: self nrValue;
		data: buffer asByteArray;
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initDataWithNInteger24bits: aCollectionOfInteger paddingFirstWith: aCollectionOfMaskInteger [
	"Padding is 32 bits (4 bytes)"

	| buffer |
	buffer := MessageBuffer new.
	1 to: aCollectionOfInteger size do: [ :i | 
		buffer
			putByteArray: ((aCollectionOfMaskInteger at: i) asByteArrayOfSize: 1).
		buffer
			putByteArray: ((aCollectionOfInteger at: i) asByteArrayOfSize: 3) ].
	^ self new
		tag_nr: self nrValue;
		data: buffer asByteArray;
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initDataWithNInteger8bits: anArrayOfInteger withPadding: aBoolean [
	"If padding, this is 32 bits-padding (4 bytes)"

	| restOfDivision buffer |
	buffer := MessageBuffer new.
	anArrayOfInteger
		do: [ :anInteger | buffer putByteArray: (anInteger asByteArrayOfSize: 1) ].
	(aBoolean
		and: [ (restOfDivision := anArrayOfInteger size \\ 4) ~= 0 ])
		ifTrue: [ 4 - restOfDivision
				timesRepeat: [ buffer putByteArray: (0 asByteArrayOfSize: 1) ] ].
	^ self new
		tag_nr: self nrValue;
		data: buffer asByteArray;
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initDataWithOne32bitsInteger: anInteger [
	^ self new
		tag_nr: self nrValue;
		data: (anInteger asByteArrayOfSize: 4);
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initDataWithThreeInteger32bits: anArrayOfInteger [
	| buffer |
	buffer := MessageBuffer new.
	buffer putLen32: (anArrayOfInteger at: 1).
	buffer putLen32: (anArrayOfInteger at: 2).
	buffer putLen32: (anArrayOfInteger at: 3).
	^ self new
		tag_nr: self nrValue;
		data: buffer asByteArray;
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initWith: aTag data: aData [
	^ self new
		tag_nr: aTag;
		data: aData;
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initWithData: aData [
	^ self new
		tag_nr: self nrValue;
		data: aData;
		yourself
]

{ #category : #'instance creation' }
M3UATag class >> initWithInteger32: anInteger [
	^ self initDataWithOne32bitsInteger: anInteger
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

{ #category : #access }
M3UATag >> length [
	^ self data size + 4
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
	aMsg putLen16: self length.
	aMsg putByteArray: self data.
	rest := self data size \\ 4.
	rest > 0
		ifTrue: [ aMsg putByteArray: (ByteArray new: 4 - rest) ]
]
