Class {
	#name : #M3UARegistrationRequestMessage,
	#superclass : #M3UARKMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #access }
M3UARegistrationRequestMessage class >> dictionaryRegistrationResult [
	| dictionary |
	dictionary := Dictionary new.
	dictionary at: 'Successfully Registered' put: 0.
	dictionary at: 'Error - Unknown' put: 1.
	dictionary at: 'Error - Invalid DPC' put: 2.
	dictionary at: 'Error - Invalid Network Appearance' put: 3.
	dictionary at: 'Error - Invalid Routing Key' put: 4.
	dictionary at: 'Error - Permission Denied' put: 5.
	dictionary at: 'Error - Cannot Support Unique Routing' put: 6.
	dictionary at: 'Error - Routing Key not Currently Provisioned' put: 7.
	dictionary at: 'Error - Insufficient Resources' put: 8.
	dictionary at: 'Error - Unsupported RK parameter Field' put: 9.
	dictionary
		at: 'Error - Unsupported/Invalid Traffic Handling Mode'
		put: 10.
	dictionary at: 'Error - Routing Key Change Refused' put: 11.
	dictionary at: 'Error - Routing Key Already Registered' put: 12.
	^ dictionary
]

{ #category : #creation }
M3UARegistrationRequestMessage class >> messageTag [
	^M3UAConstants typeRkmREGREQ

]

{ #category : #'m3ua-asp-dispatch' }
M3UARegistrationRequestMessage >> dispatchOnLogicalProcess: aSgp [
	aSgp host handleRegistrationRequest: self receivedOnSgp: aSgp

]
