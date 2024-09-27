"
Instance Variables
	dpc:		<Object>
	listOpc:		<Object>
	localRKIdentifier:		<Object>
	networkAppearance:		<Object>
	routingContext:		<Object>
	serviceIndicators:		<Object>
	trafficModeType:		<Object>


DPC and OPC list are represented in ANSI format (24 bits for Network (8bits), Cluster (6 bits), Member (10 bits))
"
Class {
	#name : #M3UARoutingKey,
	#superclass : #Object,
	#instVars : [
		'localRKIdentifier',
		'routingContext',
		'trafficModeType',
		'networkAppearance',
		'serviceIndicators',
		'listOpc',
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
		dpc: anIntegerDPC;
		yourself
]

{ #category : #'instance creation' }
M3UARoutingKey class >> fromBitmap: aBitmap [
	self flag: #todo
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
M3UARoutingKey >> listOpc [
	^ listOpc
]

{ #category : #accessing }
M3UARoutingKey >> listOpc: anObject [
	listOpc := anObject
]

{ #category : #accessing }
M3UARoutingKey >> localRKIdentifier [
	^ localRKIdentifier
]

{ #category : #accessing }
M3UARoutingKey >> localRKIdentifier: anObject [
	localRKIdentifier := anObject
]

{ #category : #accessing }
M3UARoutingKey >> networkAppearance [
	^ networkAppearance
]

{ #category : #accessing }
M3UARoutingKey >> networkAppearance: anObject [
	networkAppearance := anObject
]

{ #category : #accessing }
M3UARoutingKey >> routingContext [
	^ routingContext
]

{ #category : #accessing }
M3UARoutingKey >> routingContext: anObject [
	routingContext := anObject
]

{ #category : #accessing }
M3UARoutingKey >> serviceIndicators [
	^ serviceIndicators
]

{ #category : #accessing }
M3UARoutingKey >> serviceIndicators: anObject [
	serviceIndicators := anObject
]

{ #category : #accessing }
M3UARoutingKey >> trafficModeType [
	^ trafficModeType
]

{ #category : #accessing }
M3UARoutingKey >> trafficModeType: anObject [
	trafficModeType := anObject
]
