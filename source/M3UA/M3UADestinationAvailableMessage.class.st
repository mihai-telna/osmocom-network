Class {
	#name : #M3UADestinationAvailableMessage,
	#superclass : #M3UASSNMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UADestinationAvailableMessage class >> messageTag [
	^M3UAConstants typeSsnmDAVA

]

{ #category : #'m3ua-asp-dispatch' }
M3UADestinationAvailableMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp host handleDestinationAvailable: self receivedOnAsp: anAsp
]
