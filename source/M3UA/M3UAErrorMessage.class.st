Class {
	#name : #M3UAErrorMessage,
	#superclass : #M3UAMGMTMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UAErrorMessage class >> messageTag [
	^M3UAConstants typeMgmtERR

]

{ #category : #'m3ua-asp-dispatch' }
M3UAErrorMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp handleError: self
]
