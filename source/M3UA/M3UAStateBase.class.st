"
Super-class for AS states and ASP states

Instance Variables
	machine:		<M3UAAsStateMachine | M3UAAspStateMachine>

"
Class {
	#name : #M3UAStateBase,
	#superclass : #Object,
	#instVars : [
		'machine'
	],
	#category : #'M3UA-States'
}

{ #category : #'instance creation' }
M3UAStateBase class >> on: aStateMachine [
	"Create a new state for an AS or ASP state machine"

	^ self new
		machine: aStateMachine;
		yourself
]

{ #category : #transition }
M3UAStateBase >> entered [
	"The state has been entered"

	
]

{ #category : #transition }
M3UAStateBase >> left [
	"The state has been left"

	
]

{ #category : #accessing }
M3UAStateBase >> machine: aM3UAAspStateMachine [
	machine := aM3UAAspStateMachine

]

{ #category : #transition }
M3UAStateBase >> moveToState: aNewState [
	machine moveToState: aNewState
]
