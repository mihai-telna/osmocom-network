Class {
	#name : #M3UAPayloadDataMessage,
	#superclass : #M3UATransferMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAPayloadDataMessage class >> messageTag [
	^M3UAConstants typeTransferDATA

]

{ #category : #'m3ua-asp-dispatch' }
M3UAPayloadDataMessage >> dispatchOnLogicalProcess: aLogicalProcess [
	aLogicalProcess host
		handlePayloadDataMessage: self
		receivedOnLogicalProcess: aLogicalProcess
]
