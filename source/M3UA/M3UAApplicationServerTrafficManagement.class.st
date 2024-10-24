Class {
	#name : #M3UAApplicationServerTrafficManagement,
	#superclass : #M3UAEntity,
	#instVars : [
		'routingContexts',
		'destinationPointCodesTrafficManagement'
	],
	#category : #'M3UA-Traffic'
}

{ #category : #routes }
M3UAApplicationServerTrafficManagement >> addRoutingKey: aM3UARoutingKey forRoutingContextId: anInteger [
	"find existing routingContext or create one if not found"

	| routingContext |
	routingContext := self routingContextWithId: anInteger.
	routingContext
		ifNil: [ routingContext := M3UARoutingContext contextId: anInteger.
			routingContexts addLast: routingContext ].

	"look if a similar routingKey don't already exists"
	(routingContext routingKeys anySatisfy: [ :rk | rk dpc = aM3UARoutingKey dpc ])
		ifTrue: [ ^ self ].

	"add the routingKey"
	routingContext routingKeys addLast: aM3UARoutingKey.

	"link the networkAppareance to the routingContext, if relevant"
	routingContext networkAppearance
		ifNil: [ aM3UARoutingKey networkAppearance
				ifNotNil: [ :anIntegerNA | routingContext networkAppearance: anIntegerNA ] ].
			
	"set the DPC as available for the RoutingContext"
	destinationPointCodesTrafficManagement availableDPC: aM3UARoutingKey dpc routingContext: routingContext
]

{ #category : #mockup }
M3UAApplicationServerTrafficManagement >> availableDestination: anIntegerDPC [
	"Put all RoutingContext available for Destination Point Code in argument"

	| dictionary |
	dictionary := destinationPointCodesTrafficManagement dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ self ].
	dictionary
		keysDo: [ :aRC | 
			self
				availableDestination: anIntegerDPC
				routingContextId: aRC routingContextId ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> availableDestination: anAffectedPointCode routingContextId: anIntegerRC [
	destinationPointCodesTrafficManagement
		availableDPC: anAffectedPointCode
		routingContext: (self routingContextWithId: anIntegerRC)
]

{ #category : #mockup }
M3UAApplicationServerTrafficManagement >> congestedDestination: anIntegerDPC [
	"Put all RoutingContext congested for Destination Point Code in argument"

	| dictionary |
	dictionary := destinationPointCodesTrafficManagement dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ self ].
	dictionary
		keysDo: [ :aRC | 
			self
				congestedDestination: anIntegerDPC
				routingContextId: aRC routingContextId ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> congestedDestination: anAffectedPointCode routingContextId: anIntegerRC [
	destinationPointCodesTrafficManagement
		congestedDPC: anAffectedPointCode
		routingContext: (self routingContextWithId: anIntegerRC)
]

{ #category : #accessing }
M3UAApplicationServerTrafficManagement >> destinationPointCodesTrafficManagement [
	^ destinationPointCodesTrafficManagement
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> handleAvailableDestinations: aCollectionOfApc routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	aCollectionOfApc
		do: [ :anIntegerPC | 
			(aCollectionOfIntegerRC isEmpty
				ifTrue: [ self routingContextsForDestinationPointCode: anIntegerPC ]
				ifFalse: [ aCollectionOfIntegerRC ])
				do:
					[ :rc | self availableDestination: anIntegerPC routingContextId: rc ] ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> handleCongestedDestinations: aCollectionOfApc routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	aCollectionOfApc
		do: [ :anIntegerPC | 
			(aCollectionOfIntegerRC isEmpty
				ifTrue: [ self routingContextsForDestinationPointCode: anIntegerPC ]
				ifFalse: [ aCollectionOfIntegerRC ])
				do:
					[ :rc | self congestedDestination: anIntegerPC routingContextId: rc ] ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> handleRestrictedDestinations: aCollectionOfApc routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	aCollectionOfApc
		do: [ :anIntegerPC | 
			(aCollectionOfIntegerRC isEmpty
				ifTrue: [ self routingContextsForDestinationPointCode: anIntegerPC ]
				ifFalse: [ aCollectionOfIntegerRC ])
				do:
					[ :rc | self restrictedDestination: anIntegerPC routingContextId: rc ] ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> handleUnavailableDestinations: aCollectionOfApc routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	aCollectionOfApc
		do: [ :anIntegerPC | 
			(aCollectionOfIntegerRC isEmpty
				ifTrue: [ self routingContextsForDestinationPointCode: anIntegerPC ]
				ifFalse: [ aCollectionOfIntegerRC ])
				do:
					[ :rc | self unavailableDestination: anIntegerPC routingContextId: rc ] ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> handleUserPartUnavailableDestination: anIntegerDPC mtp3User: anIntegerMTP3User routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	(aCollectionOfIntegerRC isEmpty
		ifTrue: [ self routingContextsForDestinationPointCode: anIntegerDPC ]
		ifFalse: [ aCollectionOfIntegerRC ])
		do: [ :rc | 
			self
				userPartUnavailableDestination: anIntegerDPC
				mtp3User: anIntegerMTP3User
				routingContextId: rc ]
]

{ #category : #initialization }
M3UAApplicationServerTrafficManagement >> initialize [
	super initialize.
	routingContexts := OrderedCollection new.
	destinationPointCodesTrafficManagement := M3UAASDestinationPointCodesTrafficManagement new
]

{ #category : #'testing availabilities' }
M3UAApplicationServerTrafficManagement >> isDestinationAvailable: anIntegerDPC networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC [
	^ destinationPointCodesTrafficManagement
		isDestinationAvailable: anIntegerDPC
		routingContextsIds: aCollectionOfIntegerRC
]

{ #category : #'testing availabilities' }
M3UAApplicationServerTrafficManagement >> isDestinationRestricted: anIntegerDPC networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC [
	^ destinationPointCodesTrafficManagement
		isDestinationRestricted: anIntegerDPC
		routingContextsIds: aCollectionOfIntegerRC
]

{ #category : #'testing availabilities' }
M3UAApplicationServerTrafficManagement >> isDestinationUnavailable: anIntegerDPC networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC [
	^ destinationPointCodesTrafficManagement
		isDestinationUnavailable: anIntegerDPC
		routingContextsIds: aCollectionOfIntegerRC
]

{ #category : #'testing availabilities' }
M3UAApplicationServerTrafficManagement >> isDestinationUserPartUnavailable: anIntegerDPC mtp3User: anOtherInteger networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC [
	^ destinationPointCodesTrafficManagement
		isDestinationUserPartUnavailable: anIntegerDPC
		mtp3User: anOtherInteger
		routingContextsIds: aCollectionOfIntegerRC
]

{ #category : #'testing availabilities' }
M3UAApplicationServerTrafficManagement >> isExistingCongestionForDestination: anIntegerDPC networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC [
	^ destinationPointCodesTrafficManagement
		isExistingCongestionForDestination: anIntegerDPC
		routingContextsIds: aCollectionOfIntegerRC
]

{ #category : #routes }
M3UAApplicationServerTrafficManagement >> removeAllRoutingKeysOfRoutingContext: anInteger [
	| routingContext |
	(routingContext := self routingContextWithId: anInteger)
		ifNil: [ ^ self ].
	routingContexts remove: routingContext.

	"set all DPC as unavailable for the RoutingContext"
	(routingContext routingKeys collect: [ :rk | rk dpc ])
		do: [ :dpc | 
			destinationPointCodesTrafficManagement
				unavailableDPC: dpc
				routingContext: routingContext ]
]

{ #category : #mockup }
M3UAApplicationServerTrafficManagement >> removeDestination: anIntegerDPC [
	destinationPointCodesTrafficManagement removeDestination: anIntegerDPC
]

{ #category : #mockup }
M3UAApplicationServerTrafficManagement >> restrictedDestination: anIntegerDPC [
	"Put all RoutingContext restricted for Destination Point Code in argument"

	| dictionary |
	dictionary := destinationPointCodesTrafficManagement dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ self ].
	dictionary
		keysDo: [ :aRC | 
			self
				restrictedDestination: anIntegerDPC
				routingContextId: aRC routingContextId ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> restrictedDestination: anAffectedPointCode routingContextId: anIntegerRC [
	destinationPointCodesTrafficManagement
		restrictedDPC: anAffectedPointCode
		routingContext: (self routingContextWithId: anIntegerRC)
]

{ #category : #access }
M3UAApplicationServerTrafficManagement >> routingContextWithId: anInteger [
	^ routingContexts
		detect: [ :rc | rc routingContextId = anInteger ]
		ifNone: [ nil ]
]

{ #category : #accessing }
M3UAApplicationServerTrafficManagement >> routingContexts [
	^ routingContexts
]

{ #category : #access }
M3UAApplicationServerTrafficManagement >> routingContextsForDestinationPointCode: anIntegerDPC [
	^ routingContexts
		select:
			[ :rc | rc routingKeys anySatisfy: [ :rk | rk dpc = anIntegerDPC ] ]
]

{ #category : #access }
M3UAApplicationServerTrafficManagement >> routingContextsIds [
	^ (routingContexts collect: [ :rc | rc routingContextId ]) asSet
		asOrderedCollection
]

{ #category : #access }
M3UAApplicationServerTrafficManagement >> routingKeysForDestinationPointCode: anIntegerDPC [
	| routingKeys |
	routingKeys := OrderedCollection new.
	routingContexts
		do: [ :rc | 
			rc routingKeys
				do: [ :rk | 
					rk dpc = anIntegerDPC
						ifTrue: [ routingKeys addLast: rk ] ] ].
	^ routingKeys
]

{ #category : #access }
M3UAApplicationServerTrafficManagement >> supportedNetworkAppearances [
	^ (routingContexts collect: [ :rc | rc networkAppearance ]) asSet
		asOrderedCollection
]

{ #category : #mockup }
M3UAApplicationServerTrafficManagement >> unavailableDestination: anIntegerDPC [
	"Put all RoutingContext unavailable for Destination Point Code in argument"

	| dictionary |
	dictionary := destinationPointCodesTrafficManagement dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ self ].
	dictionary
		keysDo: [ :aRC | 
			self
				unavailableDestination: anIntegerDPC
				routingContextId: aRC routingContextId ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> unavailableDestination: anAffectedPointCode routingContextId: anIntegerRC [
	destinationPointCodesTrafficManagement
		unavailableDPC: anAffectedPointCode
		routingContext: (self routingContextWithId: anIntegerRC)
]

{ #category : #access }
M3UAApplicationServerTrafficManagement >> unavailableDestinations [
	^ destinationPointCodesTrafficManagement unavailableDestinations
]

{ #category : #access }
M3UAApplicationServerTrafficManagement >> unavailableRoutingContexts [
	^ destinationPointCodesTrafficManagement unavailableRoutingContexts
]

{ #category : #access }
M3UAApplicationServerTrafficManagement >> unavailableRoutingContextsIds [
	^ self unavailableRoutingContexts
		collect: [ :rc | rc routingContextId ]
]

{ #category : #mockup }
M3UAApplicationServerTrafficManagement >> userPartUnavailableDestination: anIntegerDPC mtp3User: anOtherInteger [
	"Put all RoutingContext userPartUnavailable for Destination Point Code in argument"

	| dictionary |
	dictionary := destinationPointCodesTrafficManagement dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ self ].
	dictionary
		keysDo: [ :aRC | 
			self
				userPartUnavailableDestination: anIntegerDPC
				mtp3User: anOtherInteger
				routingContextId: aRC routingContextId ]
]

{ #category : #'setting availabilities' }
M3UAApplicationServerTrafficManagement >> userPartUnavailableDestination: anAffectedPointCode mtp3User: anOtherInteger routingContextId: anIntegerRC [
	destinationPointCodesTrafficManagement
		userPartUnavailableDPC: anAffectedPointCode
		mtp3User: anOtherInteger 
		routingContext: (self routingContextWithId: anIntegerRC)
]
