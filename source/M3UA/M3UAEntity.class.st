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
	debugOn := true
]

{ #category : #logging }
M3UAEntity >> logDebug: aMessage area: anArea [
	debugOn ifFalse: [ ^ self ].
	super logDebug: aMessage area: anArea
]

{ #category : #access }
M3UAEntity >> putDebugOff [
	debugOn := false
]

{ #category : #access }
M3UAEntity >> putDebugOn [
	debugOn := true
]
