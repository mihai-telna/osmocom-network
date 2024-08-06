"
ASP State Transition Diagram
"
Class {
	#name : #M3UAAspState,
	#superclass : #M3UAStateBase,
	#category : #'M3UA-States'
}

{ #category : #states }
M3UAAspState class >> nextPossibleStates [
	^ self subclassResponsibility
]

{ #category : #'state-changes' }
M3UAAspState >> nextPossibleStates [
	^ self class nextPossibleStates
]
