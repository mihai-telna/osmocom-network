Class {
	#name : #M3UADestinationStateAuditMessage,
	#superclass : #M3UASSNMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UADestinationStateAuditMessage class >> messageTag [
	^ M3UAConstants typeSsnmDAUD
]

{ #category : #'m3ua-asp-dispatch' }
M3UADestinationStateAuditMessage >> dispatchOnLogicalProcess: aSGP [
	aSGP host handleDestinationStateAudit: self receivedOnSGP: aSGP
]
