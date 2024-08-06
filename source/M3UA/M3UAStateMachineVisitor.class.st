Class {
	#name : #M3UAStateMachineVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'states'
	],
	#category : #'M3UA-States'
}

{ #category : #states }
M3UAStateMachineVisitor >> acceptMessageNode: aNode [
	aNode selector = #moveToState:
		ifTrue: [ self addTransition: aNode arguments first name asString ].
	super acceptMessageNode: aNode
]

{ #category : #states }
M3UAStateMachineVisitor >> addTransition: aStateName [
	self stateSet add: aStateName
]

{ #category : #states }
M3UAStateMachineVisitor >> stateSet [
	^ states ifNil: [ states := Set new ]
]
