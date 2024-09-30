Class {
	#name : #M3UADeregistrationResponseMessage,
	#superclass : #M3UARKMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UADeregistrationResponseMessage class >> messageTag [
	^M3UAConstants typeRkmDEREGRSP

]

{ #category : #'m3ua-asp-dispatch' }
M3UADeregistrationResponseMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp host handleDeregistrationResponse: self

]
