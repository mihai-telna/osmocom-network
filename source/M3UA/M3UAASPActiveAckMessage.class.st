Class {
	#name : #M3UAASPActiveAckMessage,
	#superclass : #M3UAASPTMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPActiveAckMessage class >> messageTag [
	^M3UAConstants typeAspTmASPACACK

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPActiveAckMessage >> dispatchOnAsp: anAsp [
	anAsp handleAspActiveAck: self
]
