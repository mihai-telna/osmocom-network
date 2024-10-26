"
M3UAErrorMessage can be sent by SGP or ASP
"
Class {
	#name : #M3UAErrorMessage,
	#superclass : #M3UAMGMTMessage,
	#category : #'M3UA-Messages'
}

{ #category : #access }
M3UAErrorMessage class >> dictionaryErrorCodes [
	| dictionary |
	dictionary := Dictionary new.
	dictionary at: 'Invalid Version' put: '01'.
	dictionary at: 'Not Used in M3UA' put: '02'.
	dictionary at: 'Unsupported Message Class' put: '03'.
	dictionary at: 'Unsupported Message Type' put: '04'.
	dictionary at: 'Unsupported Traffic Mode Type' put: '05'.
	dictionary at: 'Unexpected Message' put: '06'.
	dictionary at: 'Protocol Error' put: '07'.
	dictionary at: 'Not Used in M3UA' put: '08'.
	dictionary at: 'Invalid Stream Identifier' put: '09'.
	dictionary at: 'Not Used in M3UA' put: '0a'.
	dictionary at: 'Not Used in M3UA' put: '0b'.
	dictionary at: 'Not Used in M3UA' put: '0c'.
	dictionary at: 'Refused - Management Blocking' put: '0d'.
	dictionary at: 'ASP Identifier Required' put: '0e'.
	dictionary at: 'Invalid ASP Identifier' put: '0f'.
	dictionary at: 'Not Used in M3UA' put: '10'.
	dictionary at: 'Invalid Parameter Value' put: '11'.
	dictionary at: 'Parameter Field Error' put: '12'.
	dictionary at: 'Unexpected Parameter' put: '13'.
	dictionary at: 'Destination Status Unknown' put: '14'.
	dictionary at: 'Invalid Network Appearance' put: '15'.
	dictionary at: 'Missing Parameter' put: '16'.
	dictionary at: 'Not Used in M3UA' put: '17'.
	dictionary at: 'Not Used in M3UA' put: '18'.
	dictionary at: 'Invalid Routing Context' put: '19'.
	dictionary at: 'No Configured AS for ASP' put: '1a'.
	^ dictionary
]

{ #category : #access }
M3UAErrorMessage class >> errorCodeFrom: aString [
	^ self dictionaryErrorCodes at: aString ifAbsent: [ 18 ]
]

{ #category : #creation }
M3UAErrorMessage class >> messageTag [
	^M3UAConstants typeMgmtERR

]

{ #category : #'m3ua-asp-dispatch' }
M3UAErrorMessage >> dispatchOnLogicalProcess: aLogicalEntityProcess [
	aLogicalEntityProcess handleError: self
]
