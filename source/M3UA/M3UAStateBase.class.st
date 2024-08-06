Class {
	#name : #M3UAStateBase,
	#superclass : #Object,
	#instVars : [
		'machine'
	],
	#category : #'M3UA-States'
}

{ #category : #graphviz }
M3UAStateBase class >> addStateFrom: aMethod to: newState class: aClass on: aStream [
	aStream
		nextPutAll: aClass name asString;
		nextPutAll: ' -> ';
		nextPutAll: newState;
		nextPutAll: ' [ label = "';
		nextPutAll: aMethod asString allButLast;
		nextPutAll: '"];';
		cr;
		lf
]

{ #category : #graphviz }
M3UAStateBase class >> generateGraphviz [
	| stream |
	stream := WriteStream on: String new.
	stream
	    nextPutAll: 'digraph {';
	    cr;
	    lf.
	self subclassesDo: 
		[:class | 
		class selectors do: 
			[:selector | 
			| codeVisitor method |
			method := class >> selector.
			codeVisitor := (RBParser parseMethod: method sourceCode) body 
				    acceptVisitor: M3UAStateMachineVisitor new.
			codeVisitor stateSet do: 
				[:newState | 
				self 
				    addStateFrom: method selector asString
				    to: newState
				    class: class
				    on: stream]]].
	^stream
	    nextPutAll: '}';
	    contents

]

{ #category : #'instance creation' }
M3UAStateBase class >> on: aM3UAAspStateMachine [
	"Create a new state for a state machine"

	^ self new
		machine: aM3UAAspStateMachine;
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
