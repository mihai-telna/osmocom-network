Class {
	#name : #M3UAASPHeartbeatAckMessage,
	#superclass : #M3UAASPSMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPHeartbeatAckMessage class >> messageTag [
	^M3UAConstants typeAspSmBEATACK

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPHeartbeatAckMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp handleAspHeartbeatAck: self
]
