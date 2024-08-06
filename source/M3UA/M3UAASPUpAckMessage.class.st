Class {
	#name : #M3UAASPUpAckMessage,
	#superclass : #M3UAASPSMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPUpAckMessage class >> messageTag [
	^M3UAConstants typeAspSmASPUPACK

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPUpAckMessage >> dispatchOnAsp: anAsp [
	anAsp handleAspUpAck: self
]
