Class {
	#name : #M3UATagWithSubTags,
	#superclass : #M3UATag,
	#instVars : [
		'tags'
	],
	#category : #'M3UA-Tags'
}

{ #category : #'instance creation' }
M3UATagWithSubTags class >> copyFromOtherTag: anOtherTag [
	| tag |
	tag := self new
		tag_nr: anOtherTag nr;
		yourself.
	tag copyDataFromOtherTag: anOtherTag.
	^ tag
]

{ #category : #access }
M3UATagWithSubTags class >> nrValue [
	^ -1
]

{ #category : #tags }
M3UATagWithSubTags >> addTag: aTag [
	self tags add: aTag
]

{ #category : #copying }
M3UATagWithSubTags >> copyDataFromOtherTag: aTag [

	| stream |
	stream := aTag data readStream.
	self parseTags: stream to: stream size

]

{ #category : #access }
M3UATagWithSubTags >> data [
	| tag_data |
	tag_data := MessageBuffer new.
	tags do: [ :each | each writeOn: tag_data ].
	^ tag_data asByteArray
]

{ #category : #tags }
M3UATagWithSubTags >> findTag: aTagIdentifier [
	^ self findTag: aTagIdentifier ifAbsent: [ nil ]
]

{ #category : #tags }
M3UATagWithSubTags >> findTag: aTagIdentifier ifAbsent: aBlock [
	"I find a tag with a tag identifier"

	self tags
		do: [ :each | 
			(each isTag: aTagIdentifier)
				ifTrue: [ ^ each ] ].
	^ aBlock value
]

{ #category : #initialization }
M3UATagWithSubTags >> initialize [
	super initialize.
	tags := OrderedCollection new
]

{ #category : #access }
M3UATagWithSubTags >> length [
	| size |
	size := 0.
	tags do: [ :tag | size := size + tag length ].
	^ size + 4
]

{ #category : #parsing }
M3UATagWithSubTags >> parseFrom: aStream [
	| len padding |
	tag_nr := ((aStream next: 2) shortAt: 1) swap16.
	len := ((aStream next: 2) shortAt: 1) swap16.
	self parseTags: aStream to: len - 4.
	padding := len \\ 4.
	padding > 0
		ifTrue: [ self
				logNotice: ('Going to skip <1p> bytes' expandMacrosWith: 4 - padding)
				area: #m3ua.
			aStream skip: 4 - padding ]
]

{ #category : #parsing }
M3UATagWithSubTags >> parseTags: aStream to: end [
	tags := OrderedCollection new.
	[ aStream position < end ]
		whileTrue: [ tags add: (M3UATag parseToClassFromStream: aStream) ].
	^ tags
]

{ #category : #tags }
M3UATagWithSubTags >> tags [
	^ tags
]
