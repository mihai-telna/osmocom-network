Class {
	#name : #M3UAAspStateMachineTest,
	#superclass : #TestCase,
	#category : #'M3UA-Tests'
}

{ #category : #tests }
M3UAAspStateMachineTest >> testLegalTransitions [
	| machine |
	machine := M3UAAspStateMachine new.
	self assert: machine state class equals: M3UAAspStateDown.
	machine aspUP: 'Link is up'.
	self assert: machine state class equals: M3UAAspStateInactive.
	machine aspAC: 'Active'.
	self assert: machine state class equals: M3UAAspStateActive.
	machine aspIA: 'Inactive'.
	self assert: machine state class equals: M3UAAspStateInactive.
	machine aspAC: 'Active'.
	self assert: machine state class equals: M3UAAspStateActive.
	machine sctpCdi: 'Connection is gone'.
	self assert: machine state class equals: M3UAAspStateDown.
	machine aspUP: 'Link is up'.
	self assert: machine state class equals: M3UAAspStateInactive.
	machine aspDN: 'Link is down'.
	self assert: machine state class equals: M3UAAspStateDown.
	machine aspUP: 'Link is up'.
	self assert: machine state class equals: M3UAAspStateInactive.
	machine aspAC: 'Active'.
	self assert: machine state class equals: M3UAAspStateActive.
	machine aspDN: 'Link is down'.
	self assert: machine state class equals: M3UAAspStateDown.
	machine aspUP: 'Link is up'.
	self assert: machine state class equals: M3UAAspStateInactive.
	machine aspAC: 'Active'.
	self assert: machine state class equals: M3UAAspStateActive.
	machine otherAspInAsOverrides: 'Other ASP in AS Overrides'.
	self assert: machine state class equals: M3UAAspStateInactive.
	machine aspAC: 'Active'.
	self assert: machine state class equals: M3UAAspStateActive.
	machine sctpRi: 'Connection is gone'.
	self assert: machine state class equals: M3UAAspStateDown
]
