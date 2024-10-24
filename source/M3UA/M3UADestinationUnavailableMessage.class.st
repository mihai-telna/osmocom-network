Class {
	#name : #M3UADestinationUnavailableMessage,
	#superclass : #M3UASSNMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UADestinationUnavailableMessage class >> messageTag [
	^M3UAConstants typeSsnmDUNA

]

{ #category : #'m3ua-asp-dispatch' }
M3UADestinationUnavailableMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp host handleDestinationUnavailable: self receivedOnAsp: anAsp
]
