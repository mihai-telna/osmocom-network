Class {
	#name : #M3UARoutingContext,
	#superclass : #Object,
	#instVars : [
		'routingContextId',
		'networkAppearance',
		'routingKeys'
	],
	#category : #'M3UA-Traffic'
}

{ #category : #'instance creation' }
M3UARoutingContext class >> contextId: anInteger [
	^ self new
		routingContextId: anInteger;
		yourself
]

{ #category : #initialization }
M3UARoutingContext >> initialize [
	super initialize.
	routingKeys := OrderedCollection new.

]

{ #category : #accessing }
M3UARoutingContext >> networkAppearance [
	^ networkAppearance
]

{ #category : #accessing }
M3UARoutingContext >> networkAppearance: anObject [
	networkAppearance := anObject
]

{ #category : #accessing }
M3UARoutingContext >> routingContextId [
	^ routingContextId
]

{ #category : #accessing }
M3UARoutingContext >> routingContextId: anObject [
	routingContextId := anObject
]

{ #category : #accessing }
M3UARoutingContext >> routingKeys [
	^ routingKeys
]
