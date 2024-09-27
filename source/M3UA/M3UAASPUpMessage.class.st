Class {
	#name : #M3UAASPUpMessage,
	#superclass : #M3UAASPSMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPUpMessage class >> messageTag [
	^M3UAConstants typeAspSmASPUP

]

{ #category : #access }
M3UAASPUpMessage >> aspIdentifier [
	^ (self findTag: M3UAConstants tagASPIdentifier ifAbsent: [ ^ nil ])
		data asArray
]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPUpMessage >> dispatchOnLogicalProcess: aSGP [
	aSGP host handleAspUp: self receivedOnSGP: aSGP

]
