Class {
	#name : #M3UATagProtocolData,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagProtocolData class >> nrValue [
	^ M3UAConstants tagProtocolData
]

{ #category : #'instance creation' }
M3UATagProtocolData class >> userData: aByteArray opc: anIntegerOPC dpc: anIntegerDPC si: anIntegerSI ni: anIntegerNI mp: anIntegerMP sls: anIntegerSLS [
	| tag buffer |
	tag := self new.
	buffer := MessageBuffer new.
	buffer putLen32: anIntegerOPC.
	buffer putLen32: anIntegerDPC.
	buffer nextPut: anIntegerSI.
	buffer nextPut: anIntegerNI.
	buffer nextPut: anIntegerMP.
	buffer nextPut: anIntegerSLS.
	buffer putByteArray: aByteArray.
	tag data: buffer asByteArray.
	^ tag
]

{ #category : #access }
M3UATagProtocolData >> dpcField [
	"Destination Point Code"

	^ (self data copyFrom: 5 to: 8) asInteger
]

{ #category : #testing }
M3UATagProtocolData >> isISUP [
	^ self siField = 0
]

{ #category : #testing }
M3UATagProtocolData >> isSCCP [
	^ self siField = 3
]

{ #category : #testing }
M3UATagProtocolData >> isTUP [
	^ self siField = 1
]

{ #category : #access }
M3UATagProtocolData >> mpField [
	"Message Priority"

	^ (self data copyFrom: 11 to: 11) asInteger
]

{ #category : #access }
M3UATagProtocolData >> niField [
	" Network Indicator"

	^ (self data copyFrom: 10 to: 10) asInteger
]

{ #category : #access }
M3UATagProtocolData >> opcField [
	"Originating Point Code"

	^ (self data copyFrom: 1 to: 4) asInteger
]

{ #category : #access }
M3UATagProtocolData >> siField [
	" Service Indicator"

	^ (self data copyFrom: 9 to: 9) asInteger
]

{ #category : #access }
M3UATagProtocolData >> slsField [
	"Signalling Link Selection Code"

	^ (self data copyFrom: 12 to: 12) asInteger
]

{ #category : #access }
M3UATagProtocolData >> userProtocolData [
	"User Protocol Data"

	^ self data copyFrom: 13 to: self data size
]
