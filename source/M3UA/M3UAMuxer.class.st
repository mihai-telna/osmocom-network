Class {
	#name : #M3UAMuxer,
	#superclass : #M3UAEntity,
	#instVars : [
		'socket'
	],
	#category : #'M3UA-Communication'
}

{ #category : #creation }
M3UAMuxer class >> initOn: aSocket [
	^ self new
		socket: aSocket;
		yourself
]

{ #category : #encoding }
M3UAMuxer >> nextPut: aData [
	socket nextPut: (self prepareNext: aData)
]

{ #category : #encoding }
M3UAMuxer >> prepareNext: aData [
	"Write the data onto the stream"

	| msg |
	aData size > 16rFFFFFF
	    ifTrue: 
		[self logError: 'Too much data' area: #m3ua.
		self error: 'Too much data'].
	msg := MessageBuffer new.
	msg putByteArray: aData.
	^msg asByteArray

]

{ #category : #accessing }
M3UAMuxer >> socket: aSocket [
	socket := aSocket
]
