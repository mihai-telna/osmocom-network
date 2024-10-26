Class {
	#name : #M3UASignallingCongestionMessage,
	#superclass : #M3UASSNMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UASignallingCongestionMessage class >> messageTag [
	^ M3UAConstants typeSsnmSCON
]

{ #category : #'m3ua-asp-dispatch' }
M3UASignallingCongestionMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp host handleSignallingCongestion: self
]
