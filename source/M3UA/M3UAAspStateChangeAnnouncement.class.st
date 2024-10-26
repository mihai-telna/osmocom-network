"
This class is used for updating the AS State machine after each SP state change.

Instance Variables
	aspStateMachine:		<M3UAAspStateMachine>
	oldState:		<M3UAAspState>
	newState:		<M3UAAspState>

"
Class {
	#name : #M3UAAspStateChangeAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'aspStateMachine',
		'oldState',
		'newState'
	],
	#category : #'M3UA-States'
}

{ #category : #accessing }
M3UAAspStateChangeAnnouncement >> aspStateMachine [
	^ aspStateMachine
]

{ #category : #accessing }
M3UAAspStateChangeAnnouncement >> aspStateMachine: anObject [
	aspStateMachine := anObject
]

{ #category : #accessing }
M3UAAspStateChangeAnnouncement >> newState [
	^ newState
]

{ #category : #accessing }
M3UAAspStateChangeAnnouncement >> newState: anObject [
	newState := anObject
]

{ #category : #accessing }
M3UAAspStateChangeAnnouncement >> oldState [
	^ oldState
]

{ #category : #accessing }
M3UAAspStateChangeAnnouncement >> oldState: anObject [
	oldState := anObject
]
