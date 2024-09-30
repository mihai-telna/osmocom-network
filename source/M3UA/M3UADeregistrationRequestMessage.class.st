Class {
	#name : #M3UADeregistrationRequestMessage,
	#superclass : #M3UARKMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #access }
M3UADeregistrationRequestMessage class >> dictionaryDeregistrationResult [
	| dictionary |
	dictionary := Dictionary new.
	dictionary at: 'Successfully Deregistered' put: 0.
	dictionary at: 'Error - Unknown' put: 1.
	dictionary at: 'Error - Invalid Routing Context' put: 2.
	dictionary at: 'Error - Permission Denied' put: 3.
	dictionary at: 'Error - Not Registered' put: 4.
	dictionary at: 'Error - ASP Currently Active for Routing Context' put: 5.
	^ dictionary
]

{ #category : #creation }
M3UADeregistrationRequestMessage class >> messageTag [
	^M3UAConstants typeRkmDEREGREQ

]

{ #category : #'m3ua-asp-dispatch' }
M3UADeregistrationRequestMessage >> dispatchOnLogicalProcess: aSgp [
	aSgp host handleDeregistrationRequest: self receivedOnSgp: aSgp

]
