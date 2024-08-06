"
Application Server Process State Maintenance (ASPSM) messages
"
Class {
	#name : #M3UAASPSMMessage,
	#superclass : #M3UAMSG,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPSMMessage class >> messageClass [
	^ M3UAConstants clsASPSM
]
