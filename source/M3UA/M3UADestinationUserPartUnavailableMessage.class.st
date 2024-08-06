Class {
	#name : #M3UADestinationUserPartUnavailableMessage,
	#superclass : #M3UASSNMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UADestinationUserPartUnavailableMessage class >> messageTag [
	^ M3UAConstants typeSsnmDUPU
]

{ #category : #'m3ua-asp-dispatch' }
M3UADestinationUserPartUnavailableMessage >> dispatchOnAsp: anAsp [
	anAsp mtp3Boundary handleDestinationUserPartUnavailable: self
]
