"
Application Server Process Traffic Maintenance (ASPTM) messages
"
Class {
	#name : #M3UAASPTMMessage,
	#superclass : #M3UAMSG,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPTMMessage class >> messageClass [
	^ M3UAConstants clsASPTM
]
