Class {
	#name : #M3UAASDestinationPointCodesTrafficManagement,
	#superclass : #M3UAEntity,
	#instVars : [
		'dictRoutingContextsStatesByDPC'
	],
	#category : #'M3UA-Traffic'
}

{ #category : #'RC states' }
M3UAASDestinationPointCodesTrafficManagement class >> availableState [
	^ #available
]

{ #category : #'RC states' }
M3UAASDestinationPointCodesTrafficManagement class >> congestedState [
	^ #congested
]

{ #category : #'RC states' }
M3UAASDestinationPointCodesTrafficManagement class >> restrictedState [
	^ #restricted
]

{ #category : #'RC states' }
M3UAASDestinationPointCodesTrafficManagement class >> unavailableState [
	^ #unavailable
]

{ #category : #'RC states' }
M3UAASDestinationPointCodesTrafficManagement class >> userPartUnavailableStateForMtp3User: anIntegerMTP3User [
	M3UADestinationUserPartUnavailableMessage dictionaryMTP3UserIdentity
		keysAndValuesDo: [ :str :integer | 
			integer = anIntegerMTP3User
				ifTrue: [ ^ str asSymbol ] ].
	^ #userPartUnavailable
]

{ #category : #'traffic states' }
M3UAASDestinationPointCodesTrafficManagement >> availableDPC: anIntegerDPC routingContext: aM3UARoutingContext [
	self
		putState: self class availableState
		forRoutingContext: aM3UARoutingContext
		dpc: anIntegerDPC
]

{ #category : #'traffic states' }
M3UAASDestinationPointCodesTrafficManagement >> congestedDPC: anIntegerDPC routingContext: aM3UARoutingContext [
	self
		putState: self class congestedState
		forRoutingContext: aM3UARoutingContext
		dpc: anIntegerDPC
]

{ #category : #access }
M3UAASDestinationPointCodesTrafficManagement >> congestedDestinations [
	| destinations |
	destinations := OrderedCollection new.
	dictRoutingContextsStatesByDPC
		keysAndValuesDo: [ :dpc :dictRC | 
			dictRC
				keysAndValuesDo: [ :rc :state | 
					state = self class congestedState
						ifTrue: [ destinations addIfNotPresent: dpc ] ] ].
	^ destinations
]

{ #category : #accessing }
M3UAASDestinationPointCodesTrafficManagement >> dictRoutingContextsStatesByDPC [
	^ dictRoutingContextsStatesByDPC
]

{ #category : #initialization }
M3UAASDestinationPointCodesTrafficManagement >> initialize [
	super initialize.
	dictRoutingContextsStatesByDPC := Dictionary new
]

{ #category : #'testing availabilities' }
M3UAASDestinationPointCodesTrafficManagement >> isDestinationAvailable: anIntegerDPC routingContextsIds: aCollectionOfIntegerRC [
	| dictionary |
	dictionary := dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ false ].
	dictionary
		keysAndValuesDo: [ :aRC :symbol | 
			(symbol = self class availableState
				and: [ aCollectionOfIntegerRC includes: aRC routingContextId ])
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'testing availabilities' }
M3UAASDestinationPointCodesTrafficManagement >> isDestinationRestricted: anIntegerDPC routingContextsIds: aCollectionOfIntegerRC [
	| dictionary |
	dictionary := dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ false ].
	dictionary
		keysAndValuesDo: [ :aRC :symbol | 
			(symbol = self class restrictedState
				and: [ aCollectionOfIntegerRC includes: aRC routingContextId ])
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'testing availabilities' }
M3UAASDestinationPointCodesTrafficManagement >> isDestinationUnavailable: anIntegerDPC routingContextsIds: aCollectionOfIntegerRC [
	| dictionary |
	dictionary := dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ true ].
	dictionary
		keysAndValuesDo: [ :aRC :symbol | 
			(symbol = self class unavailableState
				and: [ aCollectionOfIntegerRC includes: aRC routingContextId ])
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'testing availabilities' }
M3UAASDestinationPointCodesTrafficManagement >> isDestinationUserPartUnavailable: anIntegerDPC mtp3User: anOtherInteger routingContextsIds: aCollectionOfIntegerRC [
	| dictionary |
	dictionary := dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ false ].
	dictionary
		keysAndValuesDo: [ :aRC :symbol | 
			(symbol = (self class userPartUnavailableStateForMtp3User: anOtherInteger)
				and: [ aCollectionOfIntegerRC includes: aRC routingContextId ])
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'testing availabilities' }
M3UAASDestinationPointCodesTrafficManagement >> isExistingCongestionForDestination: anIntegerDPC routingContextsIds: aCollectionOfIntegerRC [
	| dictionary |
	dictionary := dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsent: [ ^ false ].
	dictionary
		keysAndValuesDo: [ :aRC :symbol | 
			(symbol = self class congestedState
				and: [ aCollectionOfIntegerRC includes: aRC routingContextId ])
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'traffic states' }
M3UAASDestinationPointCodesTrafficManagement >> putState: aSymbol forRoutingContext: aM3UARoutingContext dpc: anIntegerDPC [
	| dictionaryRC |
	dictionaryRC := dictRoutingContextsStatesByDPC
		at: anIntegerDPC
		ifAbsentPut: [ Dictionary new ].
	dictionaryRC at: aM3UARoutingContext put: aSymbol
]

{ #category : #mockup }
M3UAASDestinationPointCodesTrafficManagement >> removeDestination: anIntegerDPC [
	dictRoutingContextsStatesByDPC removeKey: anIntegerDPC ifAbsent: [  ]
]

{ #category : #'traffic states' }
M3UAASDestinationPointCodesTrafficManagement >> restrictedDPC: anIntegerDPC routingContext: aM3UARoutingContext [
	self
		putState: self class restrictedState
		forRoutingContext: aM3UARoutingContext
		dpc: anIntegerDPC
]

{ #category : #access }
M3UAASDestinationPointCodesTrafficManagement >> restrictedDestinations [
	| destinations |
	destinations := OrderedCollection new.
	dictRoutingContextsStatesByDPC
		keysAndValuesDo: [ :dpc :dictRC | 
			dictRC
				keysAndValuesDo: [ :rc :state | 
					state = self class restrictedState
						ifTrue: [ destinations addIfNotPresent: dpc ] ] ].
	^ destinations
]

{ #category : #'traffic states' }
M3UAASDestinationPointCodesTrafficManagement >> unavailableDPC: anIntegerDPC routingContext: aM3UARoutingContext [
	self
		putState: self class unavailableState
		forRoutingContext: aM3UARoutingContext
		dpc: anIntegerDPC
]

{ #category : #access }
M3UAASDestinationPointCodesTrafficManagement >> unavailableDestinations [
	| destinations |
	destinations := OrderedCollection new.
	dictRoutingContextsStatesByDPC
		keysAndValuesDo: [ :dpc :dictRC | 
			dictRC
				keysAndValuesDo: [ :rc :state | 
					state = self class unavailableState
						ifTrue: [ destinations addIfNotPresent: dpc ] ] ].
	^ destinations
]

{ #category : #access }
M3UAASDestinationPointCodesTrafficManagement >> unavailableRoutingContexts [
	| routingContexts |
	routingContexts := OrderedCollection new.
	dictRoutingContextsStatesByDPC
		keysAndValuesDo: [ :dpc :dictRC | 
			dictRC
				keysAndValuesDo: [ :rc :state | 
					state = self class unavailableState
						ifTrue: [ routingContexts addLast: rc ] ] ].
	^ routingContexts
]

{ #category : #'traffic states' }
M3UAASDestinationPointCodesTrafficManagement >> userPartUnavailableDPC: anIntegerDPC mtp3User: anOtherInteger routingContext: aM3UARoutingContext [
	self
		putState: (self class userPartUnavailableStateForMtp3User: anOtherInteger)
		forRoutingContext: aM3UARoutingContext
		dpc: anIntegerDPC
]

{ #category : #access }
M3UAASDestinationPointCodesTrafficManagement >> userPartUnavailableDestinationsForMTP3User: anIntegerMTP3User [
	| destinations |
	destinations := OrderedCollection new.
	dictRoutingContextsStatesByDPC
		keysAndValuesDo: [ :dpc :dictRC | 
			dictRC
				keysAndValuesDo: [ :rc :state | 
					state
						= (self class userPartUnavailableStateForMtp3User: anIntegerMTP3User)
						ifTrue: [ destinations addIfNotPresent: dpc ] ] ].
	^ destinations
]
