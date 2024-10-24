Class {
	#name : #M3UADispatcher,
	#superclass : #M3UAEntity,
	#instVars : [
		'handlers'
	],
	#category : #'M3UA-Communication'
}

{ #category : #access }
M3UADispatcher >> addHandler: anApplication on: aBlock [
	handlers at: anApplication put: aBlock
]

{ #category : #access }
M3UADispatcher >> addHandler: anApplication on: anObject with: aSelector [
	aSelector numArgs = 1
		ifTrue: [ handlers
				at: anApplication
				put: [ :msg | anObject perform: aSelector with: msg ].
			^ self ].
	aSelector numArgs = 2
		ifTrue: [ handlers
				at: anApplication
				put: [ :msg :delegate | anObject perform: aSelector with: msg with: delegate ].
			^ self ]
]

{ #category : #dispatching }
M3UADispatcher >> dispatch: anApplication with: aData fromDelegate: aDelegate [
	| handler |
	
	"debug"
	self logDebug: ' dispatch:with:fromDelegate: ' , aData class name.
	"end debug"

	handler := handlers at: anApplication
		    ifAbsent: 
			[self logError: ('M3UADispatcher has no registered handler for <1p>' 
				    expandMacrosWith: anApplication)
			    area: #m3ua.
			^false].
		
	"debug"
	self logDebug: ' handler : ' , handler printString.
	"end debug"

	handler value: aData value: aDelegate

]

{ #category : #accessing }
M3UADispatcher >> handlers [
	^ handlers
]

{ #category : #initialization }
M3UADispatcher >> initialize [
	super initialize.
	handlers := Dictionary new
]
