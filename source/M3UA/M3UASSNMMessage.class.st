"
SS7 Signalling Network Management (SSNM) Messages
"
Class {
	#name : #M3UASSNMMessage,
	#superclass : #M3UAMSG,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UASSNMMessage class >> messageClass [
	^ M3UAConstants clsSSNM
]
