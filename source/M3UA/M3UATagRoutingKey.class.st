Class {
	#name : #M3UATagRoutingKey,
	#superclass : #M3UATagWithSubTags,
	#category : #'M3UA-Tags'
}

{ #category : #'instance creation' }
M3UATagRoutingKey class >> fromRoutingKey: aM3UARoutingKey [
	| tagRoutingKey serviceIndicators opcs |
	tagRoutingKey := self new.
	aM3UARoutingKey localRKIdentifier
		ifNotNil: [ :anInteger | 
			tagRoutingKey
				addTag: (M3UATagLocalRoutingKeyIdentifier initWithInteger32: anInteger) ].
	aM3UARoutingKey routingContextId
		ifNotNil:
			[ :rc | tagRoutingKey addTag: (M3UATagRoutingContext initWithInteger32: rc) ].
	aM3UARoutingKey trafficModeType
		ifNotNil: [ :anInteger | 
			tagRoutingKey
				addTag: (M3UATagTrafficModeType initWithInteger32: anInteger) ].
	aM3UARoutingKey networkAppearance
		ifNotNil: [ :anInteger | 
			tagRoutingKey
				addTag: (M3UATagNetworkAppearance initWithInteger32: anInteger) ].
	(serviceIndicators := aM3UARoutingKey serviceIndicators) isEmpty
		ifFalse: [ tagRoutingKey
				addTag:
					(M3UATagServiceIndicators
						initDataWithNInteger8bits: serviceIndicators
						withPadding: true) ].
	(opcs := aM3UARoutingKey listOpc) isEmpty
		ifFalse: [ tagRoutingKey
				addTag:
					(M3UATagOriginatingPointCodeList
						initDataWithNInteger24bits: opcs
						paddingFirstWith: (opcs collect: [ :opc | 0 ])) ].
	aM3UARoutingKey dpc
		ifNotNil: [ :anInteger | 
			tagRoutingKey
				addTag:
					(M3UATagDestinationPointCode
						initDataWithInteger24bits: anInteger
						paddingFirstWith: 0) ].
	^ tagRoutingKey
]

{ #category : #access }
M3UATagRoutingKey class >> nrValue [
	^ M3UAConstants tagRoutingKey
]
