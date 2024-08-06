Class {
	#name : #M3UAASPDownAckMessage,
	#superclass : #M3UAASPSMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPDownAckMessage class >> messageTag [
	^M3UAConstants typeAspSmASPDNACK

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPDownAckMessage >> dispatchOnAsp: anAsp [
	anAsp handleAspDownAck: self
]
