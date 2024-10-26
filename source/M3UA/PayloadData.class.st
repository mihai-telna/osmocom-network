Class {
	#name : #PayloadData,
	#superclass : #Object,
	#instVars : [
		'data',
		'opc',
		'dpc',
		'networkAppearance',
		'routingContextId',
		'serviceIndicator',
		'networkIndicator',
		'sls',
		'messagePriority',
		'correlationId'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
PayloadData class >> fromMessage: aM3UAPayloadDataMessage [
	| tagProtocolData payloadData tagNetworkAppearance tagRoutingContext tagCorrelationId |
	tagProtocolData := aM3UAPayloadDataMessage
		findTag: M3UAConstants tagProtocolData
		ifAbsent: [ ^ nil ].
	tagNetworkAppearance := aM3UAPayloadDataMessage
		findTag: M3UAConstants tagNetworkAppearance.
	tagRoutingContext := aM3UAPayloadDataMessage
		findTag: M3UAConstants tagRoutingContext.
	tagCorrelationId := aM3UAPayloadDataMessage
		findTag: M3UAConstants tagCorrelationID.
	payloadData := self new
		data: tagProtocolData userProtocolData;
		opc: tagProtocolData opcField;
		dpc: tagProtocolData dpcField;
		serviceIndicator: tagProtocolData siField;
		networkIndicator: tagProtocolData niField;
		messagePriority: tagProtocolData mpField;
		sls: tagProtocolData slsField;
		yourself.
	tagNetworkAppearance
		ifNotNil: [ :tag | payloadData networkAppearance: tag data asInteger ].
	tagRoutingContext
		ifNotNil: [ :tag | payloadData routingContextId: tag data asInteger ].
	tagCorrelationId
		ifNotNil: [ :tag | payloadData correlationId: tag data asInteger ].
	^ payloadData
]

{ #category : #accessing }
PayloadData >> correlationId [
	^ correlationId
]

{ #category : #accessing }
PayloadData >> correlationId: anObject [
	correlationId := anObject
]

{ #category : #accessing }
PayloadData >> data [
	^ data
]

{ #category : #accessing }
PayloadData >> data: anObject [
	data := anObject
]

{ #category : #accessing }
PayloadData >> dpc [
	^ dpc
]

{ #category : #accessing }
PayloadData >> dpc: anObject [
	dpc := anObject
]

{ #category : #accessing }
PayloadData >> messagePriority [
	^ messagePriority
]

{ #category : #accessing }
PayloadData >> messagePriority: anObject [
	messagePriority := anObject
]

{ #category : #accessing }
PayloadData >> networkAppearance [
	^ networkAppearance
]

{ #category : #accessing }
PayloadData >> networkAppearance: anObject [
	networkAppearance := anObject
]

{ #category : #accessing }
PayloadData >> networkIndicator [
	^ networkIndicator
]

{ #category : #accessing }
PayloadData >> networkIndicator: anObject [
	networkIndicator := anObject
]

{ #category : #accessing }
PayloadData >> opc [
	^ opc
]

{ #category : #accessing }
PayloadData >> opc: anObject [
	opc := anObject
]

{ #category : #accessing }
PayloadData >> routingContextId [
	^ routingContextId
]

{ #category : #accessing }
PayloadData >> routingContextId: anObject [
	routingContextId := anObject
]

{ #category : #accessing }
PayloadData >> serviceIndicator [
	^ serviceIndicator
]

{ #category : #accessing }
PayloadData >> serviceIndicator: anObject [
	serviceIndicator := anObject
]

{ #category : #accessing }
PayloadData >> sls [
	^ sls
]

{ #category : #accessing }
PayloadData >> sls: anObject [
	sls := anObject
]
