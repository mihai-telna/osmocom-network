Class {
	#name : #M3UARoutingKey,
	#superclass : #Object,
	#instVars : [
		'opc',
		'dpc'
	],
	#category : #'M3UA-Core'
}

{ #category : #access }
M3UARoutingKey class >> defaultBitmapSize [
	^ 16
]

{ #category : #'instance creation' }
M3UARoutingKey class >> dpc: anIntegerDPC [
	^ self new
		opc: 0;
		dpc: anIntegerDPC;
		yourself
]

{ #category : #'instance creation' }
M3UARoutingKey class >> fromBitmap: aBitmap [
	self flag: #todo
]

{ #category : #'instance creation' }
M3UARoutingKey class >> opc: anIntegerOPC dpc: anIntegerDPC [
	^ self new
		opc: anIntegerOPC;
		dpc: anIntegerDPC;
		yourself
]

{ #category : #converting }
M3UARoutingKey >> asBitmap [
	^ self asBitmapOfSize: self class defaultBitmapSize
]

{ #category : #converting }
M3UARoutingKey >> asBitmapOfSize: anInteger [
	| bitmap |
	(opc between: 0 and: 255)
		ifFalse: [ ^ self error: 'opc must be beetween 0 and 255' ].
	(dpc between: 0 and: 255)
		ifFalse: [ ^ self error: 'dpc must be beetween 0 and 255' ].
	bitmap := Bitmap new: anInteger.

	"Store opc in the first bits"
	1 to: anInteger / 2 do: [ :index | 
		bitmap
			at: index
			put: ((opc bitAnd: (1 bitShift: anInteger / 2 - index)) > 0) asBit ].

	"Store dpc in the last bits"
	1 to: anInteger / 2 do: [ :index | 
		bitmap
			at: anInteger / 2 + index
			put: ((dpc bitAnd: (1 bitShift: anInteger / 2 - index)) > 0) asBit ].
	^ bitmap
]

{ #category : #accessing }
M3UARoutingKey >> dpc [
	^ dpc
]

{ #category : #accessing }
M3UARoutingKey >> dpc: anObject [
	dpc := anObject
]

{ #category : #accessing }
M3UARoutingKey >> opc [
	^ opc
]

{ #category : #accessing }
M3UARoutingKey >> opc: anObject [
	opc := anObject
]
