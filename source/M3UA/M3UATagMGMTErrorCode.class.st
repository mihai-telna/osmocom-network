Class {
	#name : #M3UATagMGMTErrorCode,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagMGMTErrorCode class >> invalidRoutingContextValue [
	^ 25
]

{ #category : #access }
M3UATagMGMTErrorCode class >> missingParameter [
	^ 16
]

{ #category : #access }
M3UATagMGMTErrorCode class >> nrValue [
	^ M3UAConstants tagMGMTErrorCode
]

{ #category : #access }
M3UATagMGMTErrorCode class >> unsupportedMessageType [
	^ 4
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isASPIdentifierRequired [
	^ self data asInteger = 14
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isDestinationStatusUnknown [
	^ self data asInteger = 20
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isInvalidASPIdentifier [
	^ self data asInteger = 15
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isInvalidNetworkAppearance [
	^ self data asInteger = 21
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isInvalidParameterValue [
	^ self data asInteger = 17
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isInvalidRoutingContext [
	^ self data asInteger = 25
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isInvalidStreamIdentifier [
	^ self data asInteger = 9
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isInvalidVersion [
	^ self data asInteger = 1
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isMissingParameter [
	^ self data asInteger = 22
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isNoConfiguredASForASP [
	^ self data asInteger = 26
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isNotUsedInM3UA [
	| n |
	^ (n := self data asInteger) = 2
		or: [ n = 8
				or: [ n = 10
						or: [ n = 11 or: [ n = 12 or: [ n = 16 or: [ n = 23 or: [ n = 24 ] ] ] ] ] ] ]
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isParameterFieldError [
	^ self data asInteger = 18
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isProtocolError [
	^ self data asInteger = 7
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isRefusedManagementBlocking [
	^ self data asInteger = 13
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isUnexpectedMessage [
	^ self data asInteger = 6
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isUnexpectedParameter [
	^ self data asInteger = 19
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isUnsupportedMessageClass [
	^ self data asInteger = 3
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isUnsupportedMessageType [
	^ self data asInteger = 4
]

{ #category : #testing }
M3UATagMGMTErrorCode >> isUnsupportedTrafficModeType [
	^ self data asInteger = 5
]
