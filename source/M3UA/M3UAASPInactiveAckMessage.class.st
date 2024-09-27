Class {
	#name : #M3UAASPInactiveAckMessage,
	#superclass : #M3UAASPTMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPInactiveAckMessage class >> messageTag [
	^M3UAConstants typeAspTmASPIAACK

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPInactiveAckMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp handleAspInactiveAck: self
]
