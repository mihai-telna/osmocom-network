Class {
	#name : #M3UAAspStateMachine,
	#superclass : #Object,
	#instVars : [
		'state',
		'announcer',
		'asp'
	],
	#category : #'M3UA-States'
}

{ #category : #access }
M3UAAspStateMachine class >> initialState [
	^ M3UAAspStateDown
]

{ #category : #'instance creation' }
M3UAAspStateMachine class >> onAsp: aM3UAApplicationServerProcess [
	| aspStateMachine |
	aspStateMachine := self new
		asp: aM3UAApplicationServerProcess;
		yourself.
	aM3UAApplicationServerProcess aspStateMachine: aspStateMachine.
	^ aspStateMachine
]

{ #category : #accessing }
M3UAAspStateMachine >> announcer [
	^ announcer
]

{ #category : #accessing }
M3UAAspStateMachine >> asp [
	^ asp
]

{ #category : #accessing }
M3UAAspStateMachine >> asp: anObject [
	asp := anObject
]

{ #category : #events }
M3UAAspStateMachine >> aspAC: anEvent [
	"ACTIVE notification"

	state onAspAC: anEvent
]

{ #category : #events }
M3UAAspStateMachine >> aspDN: anEvent [
	"SCTP DOWN notification"

	state onAspDN: anEvent
]

{ #category : #events }
M3UAAspStateMachine >> aspIA: anEvent [
	"INACTIVE notification"

	state onAspIA: anEvent
]

{ #category : #events }
M3UAAspStateMachine >> aspUP: anEvent [
	"SCTP UP notification"

	state onAspUP: anEvent
]

{ #category : #states }
M3UAAspStateMachine >> entered: aState [
	aState entered
]

{ #category : #initialization }
M3UAAspStateMachine >> initialize [
	state := self class initialState on: self.
	announcer := Announcer new
]

{ #category : #states }
M3UAAspStateMachine >> left: aState [
	aState left
]

{ #category : #states }
M3UAAspStateMachine >> moveToState: aNewStateClass [
	| oldState |
	oldState := state.
	state := aNewStateClass new
		machine: self;
		yourself.
	self left: oldState.
	self entered: state.
	
	announcer
		announce:
			(M3UAAspStateChangeAnnouncement new
				aspStateMachine: self;
				oldState: oldState;
				newState: state;
				yourself)
]

{ #category : #access }
M3UAAspStateMachine >> name [
	^ asp name
]

{ #category : #events }
M3UAAspStateMachine >> otherAspInAsOverrides: anEvent [
	state onOtherAspInAsOverrides: anEvent
]

{ #category : #access }
M3UAAspStateMachine >> printIdentifier [
	^ 'ASP ' , self name , ' state machine'
]

{ #category : #events }
M3UAAspStateMachine >> sctpCdi: anEvent [
	"SHUTDOWN_COMPLETE COMMUNICATION_LOST notification"

	state onSctpCdi: anEvent
]

{ #category : #events }
M3UAAspStateMachine >> sctpRi: anEvent [
	"restart notification"

	state onSctpRi: anEvent
]

{ #category : #accessing }
M3UAAspStateMachine >> state [
	^ state
]
