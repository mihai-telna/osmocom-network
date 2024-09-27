Class {
	#name : #M3UAASPDownMessage,
	#superclass : #M3UAASPSMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAASPDownMessage class >> messageTag [
	^M3UAConstants typeAspSmASPDN

]

{ #category : #'m3ua-asp-dispatch' }
M3UAASPDownMessage >> dispatchOnLogicalProcess: aSGP [
	aSGP host handleAspDown: self

]
