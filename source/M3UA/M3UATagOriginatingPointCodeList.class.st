Class {
	#name : #M3UATagOriginatingPointCodeList,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagOriginatingPointCodeList class >> nrValue [
	^ M3UAConstants tagOriginatingPointCodeList
]

{ #category : #access }
M3UATagOriginatingPointCodeList >> originatingPointCodes [
	| pointCodes |
	pointCodes := OrderedCollection new.
	1 to: (data := self data) size by: 4 do: [ :i | 
		| mask pc |
		mask := data copyFrom: i to: i.
		pc := data copyFrom: i + 1 to: i + 3.
		pointCodes addLast: pc asInteger ].
	^ pointCodes
]
