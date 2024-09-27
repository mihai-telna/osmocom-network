Class {
	#name : #M3UAASPInactiveMessage,
	#superclass : #M3UAASPTMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPInactiveMessage class >> messageTag [
	^M3UAConstants typeAspTmASPIA

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPInactiveMessage >> dispatchOnLogicalProcess: aSGP [
	aSGP host handleAspInactive: self receivedOnSGP: aSGP

]
