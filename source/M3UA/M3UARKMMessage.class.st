"
Routing Key Management (RKM) Messages
"
Class {
	#name : #M3UARKMMessage,
	#superclass : #M3UAMSG,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UARKMMessage class >> messageClass [
	^ M3UAConstants clsRKM
]
