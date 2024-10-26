Class {
	#name : #M3UADestinationUserPartUnavailableMessage,
	#superclass : #M3UASSNMMessage,
	#category : #'M3UA-Messages'
}

{ #category : #access }
M3UADestinationUserPartUnavailableMessage class >> dictionaryMTP3UserIdentity [
	| dictionary |
	dictionary := Dictionary new.
	dictionary at: 'SCCP' put: 3.
	dictionary at: 'TUP' put: 4.
	dictionary at: 'ISUP' put: 5.
	dictionary at: 'Broadband ISUP' put: 9.
	dictionary at: 'Satellite ISUP' put: 10.
	dictionary at: 'AAL type 2 Signalling' put: 12.
	dictionary at: 'Bearer Independent Call Control (BICC)' put: 13.
	dictionary at: 'Gateway Control Protocol' put: 14.
	^ dictionary
]

{ #category : #access }
M3UADestinationUserPartUnavailableMessage class >> dictionaryUnavaibilityCause [
	| dictionary |
	dictionary := Dictionary new.
	dictionary at: 'Unknown' put: 0.
	dictionary at: 'Unequipped Remote User' put: 1.
	dictionary at: 'Inaccessible Remote User' put: 2.
	^ dictionary   
]

{ #category : #creation }
M3UADestinationUserPartUnavailableMessage class >> messageTag [
	^ M3UAConstants typeSsnmDUPU
]

{ #category : #'m3ua-asp-dispatch' }
M3UADestinationUserPartUnavailableMessage >> dispatchOnLogicalProcess: anAsp [
	anAsp host handleDestinationUserPartUnavailable: self
]
