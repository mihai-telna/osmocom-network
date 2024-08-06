"
Transfer Messages
"
Class {
	#name : #M3UATransferMessage,
	#superclass : #M3UAMSG,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UATransferMessage class >> messageClass [
	^ M3UAConstants clsTransfer
]
