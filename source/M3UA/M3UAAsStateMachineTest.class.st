Class {
	#name : #M3UAAsStateMachineTest,
	#superclass : #TestCase,
	#instVars : [
		'as'
	],
	#category : #'M3UA-Tests'
}

{ #category : #tests }
M3UAAsStateMachineTest >> testDynamicTransitions [
	| machine aspMachine1 aspMachine2 aspMachine3 aspMachine4 asp1 asp2 asp3 asp4 |
	asp1 := M3UAApplicationServerProcess new
		name: 'ASP1';
		yourself.
	asp2 := M3UAApplicationServerProcess new
		name: 'ASP2';
		yourself.
	asp3 := M3UAApplicationServerProcess new
		name: 'ASP3';
		yourself.
	asp4 := M3UAApplicationServerProcess new
		name: 'ASP4';
		yourself.
	aspMachine1 := M3UAAspStateMachine onAsp: asp1.
	aspMachine2 := M3UAAspStateMachine onAsp: asp2.
	aspMachine3 := M3UAAspStateMachine onAsp: asp3.
	aspMachine4 := M3UAAspStateMachine onAsp: asp4.
	
	machine := M3UAAsStateMachine new.
	machine
		aspStateMachines:
			(OrderedCollection
				with: aspMachine1
				with: aspMachine2
				with: aspMachine3
				with: aspMachine4).
	machine requiredNumberOfAsps: 3.
	machine recoveryTimerDelayMax: 5.

	"ASP dynamic events"
	aspMachine1 aspUP: 'ASP1 is UP'.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine2 aspUP: 'ASP2 is UP'.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine3 aspUP: 'ASP3 is UP'.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine1 aspAC: 'ASP1 is active'.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine2 aspAC: 'ASP2 is active'.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine3 aspAC: 'ASP3 is active'.
	self assert: machine state class equals: M3UAAsStateActive.
	aspMachine1 sctpCdi: 'ASP1 connection is gone'.
	self assert: machine state class equals: M3UAAsStateActive.
	aspMachine2 aspDN: 'ASP2 is down'.
	self assert: machine state class equals: M3UAAsStateActive.
	aspMachine3 aspIA: 'ASP3 is inactive'.
	self assert: machine state class equals: M3UAAsStatePending.
	(Delay forSeconds: 1) wait.
	self assert: machine state class equals: M3UAAsStatePending.
	"DO NOT let the recovery timer expires"
	aspMachine3 aspAC: 'ASP3 is active'.
	self assert: machine state class equals: M3UAAsStateActive.
	aspMachine3 aspIA: 'ASP3 is inactive'.
	self assert: machine state class equals: M3UAAsStatePending.
	"let the recovery timer expires"
	[ machine recoveryTimerIsStarted ] whileTrue.
	(Delay forMilliseconds: 5) wait.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine3 aspAC: 'ASP3 is active'.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine2 aspUP: 'ASP2 is inactive'.
	aspMachine2 aspAC: 'ASP2 is active'.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine1 aspUP: 'ASP1 is inactive'.
	aspMachine1 aspAC: 'ASP1 is active'.
	self assert: machine state class equals: M3UAAsStateActive.
	aspMachine3 aspDN: 'ASP3 is down'.
	self assert: machine state class equals: M3UAAsStateActive.
	aspMachine1 aspIA: 'ASP1 is inactive'.
	aspMachine2 aspIA: 'ASP2 is inactive'.
	self assert: machine state class equals: M3UAAsStatePending.
	"let the recovery timer expires"
	[ machine recoveryTimerIsStarted ] whileTrue.
	(Delay forMilliseconds: 5) wait.
	self assert: machine state class equals: M3UAAsStateInactive.
	aspMachine1 aspAC: 'ASP1 is active'.
	aspMachine2 aspAC: 'ASP2 is active'.
	aspMachine3 aspUP: 'ASP3 is inactive'.
	aspMachine3 aspAC: 'ASP3 is active'.
	self assert: machine state class equals: M3UAAsStateActive.
	aspMachine2 aspIA: 'ASP2 is inactive'.
	aspMachine1 aspIA: 'ASP1 is inactive'.
	self assert: machine state class equals: M3UAAsStateActive.
	aspMachine3 aspIA: 'ASP3 is inactive'.
	self assert: machine state class equals: M3UAAsStatePending.
	aspMachine1 sctpCdi: 'ASP1 connection is gone'.
	aspMachine2 aspDN: 'ASP2 is down'.
	aspMachine3 sctpCdi: 'ASP3 connection is gone'.
	[ machine recoveryTimerIsStarted ] whileTrue.
	(Delay forMilliseconds: 5) wait.
	self assert: machine state class equals: M3UAAsStateDown
]

{ #category : #tests }
M3UAAsStateMachineTest >> testDynamicTransitionsWithAS [
	| machine aspMachine1 aspMachine2 aspMachine3 aspMachine4 asp1 asp2 asp3 asp4 |
	as := M3UAApplicationServer new.
	machine := as asStateMachine.
	
	asp1 := M3UAApplicationServerProcess new
		name: 'ASP1';
		yourself.
	asp2 := M3UAApplicationServerProcess new
		name: 'ASP2';
		yourself.
	asp3 := M3UAApplicationServerProcess new
		name: 'ASP3';
		yourself.
	asp4 := M3UAApplicationServerProcess new
		name: 'ASP4';
		yourself.
	aspMachine1 := M3UAAspStateMachine onAsp: asp1.
	aspMachine2 := M3UAAspStateMachine onAsp: asp2.
	aspMachine3 := M3UAAspStateMachine onAsp: asp3.
	aspMachine4 := M3UAAspStateMachine onAsp: asp4.
	as registerASP: asp1.
	as registerASP: asp2.
	as registerASP: asp3.
	as registerASP: asp4.
	machine requiredNumberOfAsps: 3.	
	machine recoveryTimerDelayMax: 5.
		
	"ASP dynamic events"
	aspMachine1 aspUP: 'ASP1 is UP'.
	self assert: machine state class equals: M3UAAsStateInactive.
		
	aspMachine2 aspUP: 'ASP2 is UP'.
	self assert: machine state class equals: M3UAAsStateInactive.
	
	aspMachine3 aspUP: 'ASP3 is UP'.
	self assert: machine state class equals: M3UAAsStateInactive.
	
	aspMachine1 aspAC: 'ASP1 is active'.
	self assert: machine state class equals: M3UAAsStateInactive.
		
	aspMachine2 aspAC: 'ASP2 is active'.
	self assert: machine state class equals: M3UAAsStateInactive.
		
	aspMachine3 aspAC: 'ASP3 is active'.
	self assert: machine state class equals: M3UAAsStateActive.
		
	aspMachine1 sctpCdi: 'ASP1 connection is gone'.
	self assert: machine state class equals: M3UAAsStateActive.
		
	aspMachine2 aspDN: 'ASP2 is down'.
	self assert: machine state class equals: M3UAAsStateActive.

	aspMachine3 aspIA: 'ASP3 is inactive'.
	self assert: machine state class equals: M3UAAsStatePending.
		
	(Delay forSeconds: 1) wait.
	self assert: machine state class equals: M3UAAsStatePending.
		
	aspMachine3 aspAC: 'ASP3 is active'.
	self assert: machine state class equals: M3UAAsStateActive.
		
	aspMachine3 aspIA: 'ASP3 is inactive'.
	self assert: machine state class equals: M3UAAsStatePending.

	[ machine recoveryTimerIsStarted ] whileTrue.
	(Delay forMilliseconds: 5) wait.
	self assert: machine state class equals: M3UAAsStateInactive.
	
	aspMachine3 aspAC: 'ASP3 is active'.
	self assert: machine state class equals: M3UAAsStateInactive.

	aspMachine2 aspUP: 'ASP2 is inactive'.
	aspMachine2 aspAC: 'ASP2 is active'.
	self assert: machine state class equals: M3UAAsStateInactive.

	aspMachine1 aspUP: 'ASP1 is inactive'.
	aspMachine1 aspAC: 'ASP1 is active'.
	self assert: machine state class equals: M3UAAsStateActive.
	
	aspMachine3 aspDN: 'ASP3 is down'.
	self assert: machine state class equals: M3UAAsStateActive.

	aspMachine1 aspIA: 'ASP1 is inactive'.
	aspMachine2 aspIA: 'ASP2 is inactive'.
	self assert: machine state class equals: M3UAAsStatePending.

	(Delay forSeconds: 1) wait.
	self assert: machine state class equals: M3UAAsStatePending.

	[ machine recoveryTimerIsStarted ] whileTrue.
	(Delay forMilliseconds: 5) wait.
	self assert: machine state class equals: M3UAAsStateInactive.
		
	aspMachine1 aspAC: 'ASP1 is active'.
	aspMachine2 aspAC: 'ASP2 is active'.
	aspMachine3 aspUP: 'ASP3 is inactive'.
	aspMachine3 aspAC: 'ASP3 is active'.
	self assert: machine state class equals: M3UAAsStateActive.

	aspMachine2 aspIA: 'ASP2 is inactive'.
	aspMachine1 aspIA: 'ASP1 is inactive'.
	self assert: machine state class equals: M3UAAsStateActive.
	
	aspMachine3 aspIA: 'ASP3 is inactive'.
	self assert: machine state class equals: M3UAAsStatePending.
	
	aspMachine1 sctpCdi: 'ASP1 connection is gone'.
	aspMachine2 aspDN: 'ASP2 is down'.
	aspMachine3 sctpCdi: 'ASP3 connection is gone'.
	
	[ machine recoveryTimerIsStarted ] whileTrue.
	(Delay forMilliseconds: 5) wait.
	self assert: machine state class equals: M3UAAsStateDown
]

{ #category : #tests }
M3UAAsStateMachineTest >> testSimpleTransitions [
	| machine |
	machine := M3UAAsStateMachine new.
	self assert: machine state class equals: M3UAAsStateDown.
	machine dn2IA: 'AS is up'.
	self assert: machine state class equals: M3UAAsStateInactive.
	machine ia2AC: 'AS is Active'.
	self assert: machine state class equals: M3UAAsStateActive.
	machine ac2PN: 'AS is pending'.
	self assert: machine state class equals: M3UAAsStatePending.
	machine pn2DN: 'AS is down'.
	self assert: machine state class equals: M3UAAsStateDown.
	machine dn2IA: 'AS is up'.
	self assert: machine state class equals: M3UAAsStateInactive.
	machine ia2DN: 'AS is down'.
	self assert: machine state class equals: M3UAAsStateDown.
	machine dn2IA: 'AS is up'.
	self assert: machine state class equals: M3UAAsStateInactive.
	machine ia2AC: 'AS is Active'.
	self assert: machine state class equals: M3UAAsStateActive.
	machine ac2PN: 'AS is pending'.
	self assert: machine state class equals: M3UAAsStatePending.
	machine pn2AC: 'AS is Active'.
	self assert: machine state class equals: M3UAAsStateActive.
	machine ac2PN: 'AS is pending'.
	self assert: machine state class equals: M3UAAsStatePending.
	machine pn2IA: 'AS is inactive'.
	self assert: machine state class equals: M3UAAsStateInactive.
	
	self should: [machine ac2PN: 'AS is pending'] raise: MessageNotUnderstood.
	

]

{ #category : #tests }
M3UAAsStateMachineTest >> testSimpleTransitionsWithAS [
	| machine |
	as := M3UAApplicationServer new.
	machine := as asStateMachine.
	self assert: machine state class equals: M3UAAsStateDown.
	machine dn2IA: 'AS is up'.
	self assert: machine state class equals: M3UAAsStateInactive.
	machine ia2AC: 'AS is Active'.
	self assert: machine state class equals: M3UAAsStateActive.
	machine ac2PN: 'AS is pending'.
	self assert: machine state class equals: M3UAAsStatePending.
	machine pn2DN: 'AS is down'.
	self assert: machine state class equals: M3UAAsStateDown.
	machine dn2IA: 'AS is up'.
	self assert: machine state class equals: M3UAAsStateInactive.
	machine ia2DN: 'AS is down'.
	self assert: machine state class equals: M3UAAsStateDown.
	machine dn2IA: 'AS is up'.
	self assert: machine state class equals: M3UAAsStateInactive.
	machine ia2AC: 'AS is Active'.
	self assert: machine state class equals: M3UAAsStateActive.
	machine ac2PN: 'AS is pending'.
	self assert: machine state class equals: M3UAAsStatePending.
	machine pn2AC: 'AS is Active'.
	self assert: machine state class equals: M3UAAsStateActive.
	machine ac2PN: 'AS is pending'.
	self assert: machine state class equals: M3UAAsStatePending.
	machine pn2IA: 'AS is inactive'.
	self assert: machine state class equals: M3UAAsStateInactive.
	
	self should: [machine ac2PN: 'AS is pending'] raise: MessageNotUnderstood.
	

]
