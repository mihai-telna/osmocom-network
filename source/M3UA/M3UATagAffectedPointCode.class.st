Class {
	#name : #M3UATagAffectedPointCode,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #'instance creation' }
M3UATagAffectedPointCode class >> initWithBitmap: aBitmap [
	"32 bits integer
	mask to add, cf RFC 4666 paragraph 3.4.1"

	| bitArray finalBitmapSize integerValue |
	finalBitmapSize := 24.
	aBitmap size = finalBitmapSize
		ifTrue: [ bitArray := aBitmap ]
		ifFalse: [ bitArray := Bitmap new: finalBitmapSize withAll: 0.
			1 to: aBitmap size do: [ :i | 
				| bit |
				bit := aBitmap at: i.
				bitArray at: i + (finalBitmapSize - aBitmap size) put: bit ] ].

	"Convert to Integer"
	integerValue := 0.
	1 to: finalBitmapSize do: [ :index | 
		integerValue := integerValue bitShift: 1.
		integerValue := integerValue bitOr: (bitArray at: index) ].
	
	^ self initWithData: (integerValue asByteArrayOfSize: 4)
]

{ #category : #'instance creation' }
M3UATagAffectedPointCode class >> initWithBitmap: aBitmap ofSize: anInteger [
	"24 or 32 bits integer
	mask to add, cf RFC 4666 paragraph 3.4.1"

	| bitArray finalBitmapSize integerValue |
	finalBitmapSize := anInteger.
	aBitmap size = finalBitmapSize
		ifTrue: [ bitArray := aBitmap ]
		ifFalse: [ bitArray := Bitmap new: finalBitmapSize withAll: 0.
			1 to: aBitmap size do: [ :i | 
				| bit |
				bit := aBitmap at: i.
				bitArray at: i + (finalBitmapSize - aBitmap size) put: bit ] ].

	"Convert to Integer"
	integerValue := 0.
	1 to: finalBitmapSize do: [ :index | 
		integerValue := integerValue bitShift: 1.
		integerValue := integerValue bitOr: (bitArray at: index) ].
	
	^ self initWithData: (integerValue asByteArrayOfSize: 4)
]

{ #category : #access }
M3UATagAffectedPointCode class >> nrValue [
	^ M3UAConstants tagAffectedPointCode
]

{ #category : #access }
M3UATagAffectedPointCode >> affectedPointCodes [
	| pointCodes |
	pointCodes := OrderedCollection new.
	1 to: (data := self data) size by: 4 do: [ :i | 
		| mask pc |
		mask := data copyFrom: i to: i.
		pc := data copyFrom: i + 1 to: i + 3.
		pointCodes addLast: pc asInteger ].
	^ pointCodes
]
