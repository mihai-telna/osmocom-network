Class {
	#name : #M3UAAsStateMachine,
	#superclass : #Object,
	#instVars : [
		'state',
		'aspStateMachines',
		'requiredNumberOfAsps',
		'recoveryTimer',
		'recoveryTimerDelayMax',
		'rt_proc',
		'logger'
	],
	#category : #'M3UA-States'
}

{ #category : #access }
M3UAAsStateMachine class >> initialState [
	^ M3UAAsStateDown
]

{ #category : #events }
M3UAAsStateMachine >> ac2PN: anEvent [
	state onAC2PN: anEvent
]

{ #category : #acccessing }
M3UAAsStateMachine >> aspStateMachines [
	^ aspStateMachines
]

{ #category : #acccessing }
M3UAAsStateMachine >> aspStateMachines: aCollection [
	aspStateMachines := aCollection.
	self handleAnnouncements
]

{ #category : #'recovery timer' }
M3UAAsStateMachine >> delayRecoveryTimerIsOver [
	| n |
	n := Time totalSeconds - recoveryTimer.
	logger logDebug: 'Recovery timer : ' with: {('delay remaining' -> n)}.
	^ n > self recoveryTimerDelayMax
]

{ #category : #events }
M3UAAsStateMachine >> dn2IA: anEvent [
	state onDN2IA: anEvent
]

{ #category : #states }
M3UAAsStateMachine >> entered: aState [
	aState entered
]

{ #category : #announcements }
M3UAAsStateMachine >> handleAnnoucement: aM3UAAspStateChangeAnnouncement [
	| newAspStateClass |
	newAspStateClass := aM3UAAspStateChangeAnnouncement newState class.
	
	logger
		logDebug: 'Annoucement for'
		with:
			{(aM3UAAspStateChangeAnnouncement aspStateMachine printIdentifier
				-> newAspStateClass printString)}.

	"state AS -  Down"
	state class = M3UAAsStateDown
		ifTrue: [ newAspStateClass = M3UAAspStateInactive
				ifTrue: [ self dn2IA: 'One ASP is UP' ] ].

	"state AS -  Inactive"
	state class = M3UAAsStateInactive
		ifTrue: [ newAspStateClass = M3UAAspStateActive
				ifTrue: [ (self numberOfAspsInStatus: M3UAAspStateActive)
						>= self requiredNumberOfAsps
						ifTrue: [ self ia2AC: 'Enough ASP are active' ] ].
			newAspStateClass = M3UAAspStateDown
				ifTrue: [ (self numberOfAspsInStatus: M3UAAspStateDown)
						= aspStateMachines size
						ifTrue: [ self ia2DN: 'All ASP are down' ] ] ].

	"state AS -  Active"
	state class = M3UAAsStateActive
		ifTrue: [ (newAspStateClass = M3UAAspStateInactive
				or: [ newAspStateClass = M3UAAspStateDown ])
				ifTrue: [ (self numberOfAspsInStatus: M3UAAspStateActive) = 0
						ifTrue: [ self startRecoveryTimer.
							self ac2PN: 'No ASP are still active' ] ] ].

	"state AS -  Pending"
	state class = M3UAAsStatePending
		ifTrue: [ (newAspStateClass = M3UAAspStateActive
				and: [ self delayRecoveryTimerIsOver not ])
				ifTrue: [ self stopRecoveryTimer.
					self pn2AC: 'AS is active again' ] ]
]

{ #category : #announcements }
M3UAAsStateMachine >> handleAnnouncementFor: aM3UAAspStateMachine [
	| announcementBlock |
	announcementBlock := [ :ann | self handleAnnoucement: ann ].
	aM3UAAspStateMachine announcer
		when: M3UAAspStateChangeAnnouncement
		do: announcementBlock
]

{ #category : #announcements }
M3UAAsStateMachine >> handleAnnouncements [
	| announcementBlock |
	announcementBlock := [ :ann | self handleAnnoucement: ann ].
	
	aspStateMachines
		do: [ :aspStateMachine | 
			aspStateMachine announcer
				when: M3UAAspStateChangeAnnouncement
				do: announcementBlock ]
]

{ #category : #events }
M3UAAsStateMachine >> ia2AC: anEvent [
	state onIA2AC: anEvent
]

{ #category : #events }
M3UAAsStateMachine >> ia2DN: anEvent [
	state onIA2DN: anEvent
]

{ #category : #initialization }
M3UAAsStateMachine >> initialize [
	state := self class initialState on: self.
	aspStateMachines := OrderedCollection new.
	recoveryTimer := nil.
	logger := LogStructuredLogger for: self area: #m3ua
]

{ #category : #states }
M3UAAsStateMachine >> left: aState [
	aState left
]

{ #category : #states }
M3UAAsStateMachine >> moveToState: aNewState [
	| oldState |
	oldState := state.
	
	logger
		logNotice: 'Moving state from '
		with: {(oldState printString -> aNewState printString)}.
		
	state := aNewState new
		machine: self;
		yourself.
	self left: oldState.
	self entered: state
]

{ #category : #states }
M3UAAsStateMachine >> numberOfAspsInStatus: aStateClass [
	^ (aspStateMachines
		select: [ :aspStateMachine | aspStateMachine state class = aStateClass ])
		size
]

{ #category : #events }
M3UAAsStateMachine >> pn2AC: anEvent [
	state onPN2AC: anEvent
]

{ #category : #events }
M3UAAsStateMachine >> pn2DN: anEvent [
	state onPN2DN: anEvent
]

{ #category : #events }
M3UAAsStateMachine >> pn2IA: anEvent [
	state onPN2IA: anEvent
]

{ #category : #'recovery timer' }
M3UAAsStateMachine >> recoveryTimerDelayMax [
	^ recoveryTimerDelayMax
]

{ #category : #'recovery timer' }
M3UAAsStateMachine >> recoveryTimerDelayMax: anInteger [
	"In seconds"

	recoveryTimerDelayMax := anInteger
]

{ #category : #'recovery timer' }
M3UAAsStateMachine >> recoveryTimerIsStarted [
	^ recoveryTimer notNil
]

{ #category : #acccessing }
M3UAAsStateMachine >> requiredNumberOfAsps [
	^ requiredNumberOfAsps
]

{ #category : #acccessing }
M3UAAsStateMachine >> requiredNumberOfAsps: anInteger [
	requiredNumberOfAsps := anInteger
]

{ #category : #'recovery timer' }
M3UAAsStateMachine >> startRecoveryTimer [
	recoveryTimer := Time totalSeconds.
	rt_proc := [ [ | isRecovery |
	(isRecovery := recoveryTimer notNil
		and: [ self delayRecoveryTimerIsOver not ])
		ifTrue: [ (Delay forSeconds: 1) wait.
			Processor yield ]
		ifFalse: [ recoveryTimer ifNotNil: [ self updateStateWhenRecoveryTimerIsOver ].
			self stopRecoveryTimer ].
	isRecovery ] whileTrue ] newProcess.
	rt_proc resume
]

{ #category : #acccessing }
M3UAAsStateMachine >> state [
	^ state
]

{ #category : #'recovery timer' }
M3UAAsStateMachine >> stopRecoveryTimer [
	recoveryTimer := nil
]

{ #category : #'recovery timer' }
M3UAAsStateMachine >> updateStateWhenRecoveryTimerIsOver [
	"Delay is over"

	| n |
	self delayRecoveryTimerIsOver
		ifFalse: [ ^ self ].
		
	logger logDebug: 'Recovery timer : ' with: {('Delay is over : ' -> true)}.

	"RFC4666
	AS-PENDING: If an ASP becomes ASP-ACTIVE before
   	T(r) expires, the AS is moved to the AS-ACTIVE state and all the
   queued messages will be sent to the ASP."
	(n := self numberOfAspsInStatus: M3UAAspStateActive) > 0
		ifTrue: [ logger
				logDebug: 'Move to sate AS-ACTIVE again : '
				with: {('Number of active ASP' -> n)}.
			self pn2AC: 'AS is active again'.
			^ self ].

	"RFC4666
	AS-PENDING: If T(r) expires before an ASP becomes ASP-ACTIVE, the SGP stops
   queuing messages and discards all previously queued messages.  The AS
   will move to the AS-INACTIVE state if at least one ASP is in the
   ASP-INACTIVE state, otherwise it will move to the AS-DOWN state."
	(n := self numberOfAspsInStatus: M3UAAspStateInactive) > 0
		ifTrue: [ logger
				logDebug: 'Move to sate AS-INACTIVE again : '
				with: {('Number of inactive ASP' -> n)}.
			self pn2IA: 'AS is inactive again' ]
		ifFalse: [ logger
				logDebug: 'Move to sate AS-DOWN : '
				with: {('Number of inactive ASP' -> n)}.
			self pn2DN: 'AS is down' ].
	^ self
]
