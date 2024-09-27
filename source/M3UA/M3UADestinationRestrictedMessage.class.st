Class {
	#name : #M3UADestinationRestrictedMessage,
	#superclass : #M3UASSNMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UADestinationRestrictedMessage class >> messageTag [
	^M3UAConstants typeSsnmDRST

]

{ #category : #'m3ua-asp-dispatch' }
M3UADestinationRestrictedMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp mtp3Boundary handleDestinationRestricted: self
]
