Class {
	#name : #M3UAMTPLevel3Boundary,
	#superclass : #M3UAEntity,
	#instVars : [
		'applicationServerProcess'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
M3UAMTPLevel3Boundary class >> on: anAsp [
	^self new
		applicationServerProcess: anAsp;
		yourself
]

{ #category : #accessing }
M3UAMTPLevel3Boundary >> applicationServerProcess [
	^ applicationServerProcess
]

{ #category : #accessing }
M3UAMTPLevel3Boundary >> applicationServerProcess: anObject [
	applicationServerProcess := anObject
]

{ #category : #'SNSM messages' }
M3UAMTPLevel3Boundary >> handleDestinationAvailable: aMsg [
	self halt
]

{ #category : #'SNSM messages' }
M3UAMTPLevel3Boundary >> handleDestinationRestricted: aMsg [
	self halt
]

{ #category : #'SNSM messages' }
M3UAMTPLevel3Boundary >> handleDestinationStateAudit: aMsg [
	self halt
]

{ #category : #'SNSM messages' }
M3UAMTPLevel3Boundary >> handleDestinationUnavailable: aMsg [
	self halt
]

{ #category : #'SNSM messages' }
M3UAMTPLevel3Boundary >> handleDestinationUserPartUnavailable: aMsg [
	self halt
]

{ #category : #'SNSM messages' }
M3UAMTPLevel3Boundary >> handleSignallingCongestion: aMsg [
	self halt
]

{ #category : #'SNSM messages' }
M3UAMTPLevel3Boundary >> handleTransferMessage: aMsg [
	| tagProtocolData |
	tagProtocolData := aMsg
		findTag: M3UAConstants tagProtocolData
		ifAbsent: [ self flag: #todo ].
	tagProtocolData isSCCP
		ifTrue: [ ^ applicationServerProcess networkService
				signalUnitData: tagProtocolData userProtocolData
				fromOpc: tagProtocolData opcField
				toDpc: tagProtocolData dpcField
				priority: tagProtocolData mpField ].
	self flag: #todo
]
