"
M3UAASPHeartbeatMessage can be sent by SGP or ASP
"
Class {
	#name : #M3UAASPHeartbeatMessage,
	#superclass : #M3UAASPSMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPHeartbeatMessage class >> messageTag [
	^M3UAConstants typeAspSmBEAT

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPHeartbeatMessage >> dispatchOnLogicalProcess: aLogicalEntityProcess [
	aLogicalEntityProcess host handleAspHeartbeat: self
]
