Class {
	#name : #M3UAEntity,
	#superclass : #Object,
	#instVars : [
		'debugOn'
	],
	#category : #'M3UA-Core'
}

{ #category : #initialization }
M3UAEntity >> initialize [
	super initialize.
	self putDebugOff
]

{ #category : #logging }
M3UAEntity >> logDebug: aMessage area: anArea [
	debugOn ifFalse: [ ^ self ].
	super logDebug: aMessage area: anArea
]

{ #category : #access }
M3UAEntity >> putDebug: aBoolean [
	debugOn := aBoolean
]

{ #category : #access }
M3UAEntity >> putDebugOff [
	self putDebug: false
]

{ #category : #access }
M3UAEntity >> putDebugOn [
	self putDebug: true
]
