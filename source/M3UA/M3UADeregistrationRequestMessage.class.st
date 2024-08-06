Class {
	#name : #M3UADeregistrationRequestMessage,
	#superclass : #M3UARKMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UADeregistrationRequestMessage class >> messageTag [
	^M3UAConstants typeRkmDEREGREQ

]

{ #category : #'m3ua-asp-dispatch' }
M3UADeregistrationRequestMessage >> dispatchOnAsp: anAsp [
	anAsp applicationServer handleDeregistrationRequest: self

]
