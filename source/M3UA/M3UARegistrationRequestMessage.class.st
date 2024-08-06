Class {
	#name : #M3UARegistrationRequestMessage,
	#superclass : #M3UARKMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UARegistrationRequestMessage class >> messageTag [
	^M3UAConstants typeRkmREGREQ

]

{ #category : #'m3ua-asp-dispatch' }
M3UARegistrationRequestMessage >> dispatchOnAsp: anAsp [
	anAsp applicationServer handleRegistrationRequest: self

]
