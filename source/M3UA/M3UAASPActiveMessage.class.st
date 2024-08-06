Class {
	#name : #M3UAASPActiveMessage,
	#superclass : #M3UAASPTMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPActiveMessage class >> messageTag [
	^M3UAConstants typeAspTmASPAC

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPActiveMessage >> dispatchOnAsp: anAsp [
	anAsp applicationServer handleAspActive: self

]
