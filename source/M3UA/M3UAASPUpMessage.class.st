Class {
	#name : #M3UAASPUpMessage,
	#superclass : #M3UAASPSMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPUpMessage class >> messageTag [
	^M3UAConstants typeAspSmASPUP

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPUpMessage >> dispatchOnAsp: anAsp [
	anAsp applicationServer handleAspUp: self

]
