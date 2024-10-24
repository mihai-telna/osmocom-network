Class {
	#name : #M3UAASPUpAckMessage,
	#superclass : #M3UAASPSMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPUpAckMessage class >> messageTag [
	^M3UAConstants typeAspSmASPUPACK

]

{ #category : #access }
M3UAASPUpAckMessage >> aspIdentifier [
	^ (self findTag: M3UAConstants tagASPIdentifier ifAbsent: [ ^ nil ])
		data asArray
]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPUpAckMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp handleAspUpAck: self
]
