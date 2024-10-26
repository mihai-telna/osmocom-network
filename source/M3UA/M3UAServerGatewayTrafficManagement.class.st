Class {
	#name : #M3UAServerGatewayTrafficManagement,
	#superclass : #M3UAEntity,
	#instVars : [
		'dictRoutingContextActivities',
		'dictNetworkAppearanceActivities'
	],
	#category : #'M3UA-Traffic'
}

{ #category : #accessing }
M3UAServerGatewayTrafficManagement >> dictNetworkAppearanceActivities [
	^ dictNetworkAppearanceActivities
]

{ #category : #accessing }
M3UAServerGatewayTrafficManagement >> dictRoutingContextActivities [
	^ dictRoutingContextActivities
]

{ #category : #'SS7 networks' }
M3UAServerGatewayTrafficManagement >> disableSS7NetworkWithAppearance: anInteger [
	dictNetworkAppearanceActivities at: anInteger put: false
]

{ #category : #'SS7 networks' }
M3UAServerGatewayTrafficManagement >> enableSS7NetworkWithAppearance: anInteger [
	dictNetworkAppearanceActivities at: anInteger put: true
]

{ #category : #'testing availabilities' }
M3UAServerGatewayTrafficManagement >> handledMtp3Users [
	| dictionary |
	dictionary := M3UADestinationUserPartUnavailableMessage
		dictionaryMTP3UserIdentity.
	^ OrderedCollection
		with: (dictionary at: 'SCCP')
		with: (dictionary at: 'ISUP')
]

{ #category : #'SS7 networks' }
M3UAServerGatewayTrafficManagement >> hasSingleSS7Network [
	^ dictNetworkAppearanceActivities keys size = 1
]

{ #category : #initialization }
M3UAServerGatewayTrafficManagement >> initialize [
	super initialize.
	dictRoutingContextActivities := Dictionary new
]

{ #category : #'testing availabilities' }
M3UAServerGatewayTrafficManagement >> isDestinationRestricted: anIntegerDPC networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC forASP: anASP [
	^ anASP host trafficManagement
		isDestinationRestricted: anIntegerDPC
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
]

{ #category : #'testing availabilities' }
M3UAServerGatewayTrafficManagement >> isDestinationUnavailable: anIntegerDPC networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC forASP: anASP [
	^ anASP host trafficManagement
		isDestinationUnavailable: anIntegerDPC
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
]

{ #category : #'testing availabilities' }
M3UAServerGatewayTrafficManagement >> isExistingCongestionForDestination: anIntegerDPC networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC forASP: anASP [
	^ anASP host trafficManagement
		isExistingCongestionForDestination: anIntegerDPC
		networkAppearance: anIntegerNA
		routingContextsIds: aCollectionOfIntegerRC
]

{ #category : #'testing availabilities' }
M3UAServerGatewayTrafficManagement >> mtp3UserUnavailableFor: anIntegerDPC networkAppearance: anIntegerNA routingContextsIds: aCollectionOfIntegerRC forASP: anASP [
	self handledMtp3Users
		do: [ :anIntegerMTP3User | 
			(anASP host trafficManagement
				isDestinationUserPartUnavailable: anIntegerDPC
				mtp3User: anIntegerMTP3User
				networkAppearance: anIntegerNA
				routingContextsIds: aCollectionOfIntegerRC)
				ifTrue: [ ^ anIntegerMTP3User ] ].
	^ nil
]
