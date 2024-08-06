Class {
	#name : #M3UATagMGMTNotifyStatus,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagMGMTNotifyStatus class >> infoASPFailure [
	^ 3
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> infoAlternateASPActive [
	^ 2
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> infoAsActive [
	^ 3
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> infoAsInactive [
	^ 2
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> infoAsPending [
	^ 4
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> infoInsufficientASPResourcesActiveInAS [
	^ 1
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> infoReserved [
	^ 1
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> nrValue [
	^ M3UAConstants tagMGMTNotifyStatus
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> statusApplicationServerStateChange [
	^ 1
]

{ #category : #access }
M3UATagMGMTNotifyStatus class >> statusOther [
	^ 2
]

{ #category : #'instance creation' }
M3UATagMGMTNotifyStatus class >> type: anInteger info: anOtherInteger [
	| tag data |
	tag := self new.
	data := ByteArray new: 4 withAll: 0.
	data
		integerAt: 2
		put: anInteger
		size: 1
		signed: false.
	data
		integerAt: 4
		put: anOtherInteger
		size: 1
		signed: false.
	tag data: data.
	^ tag
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isInfoASPFailure [
	^ self isStatusOther and: [ self statusInfo = self class infoASPFailure ]
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isInfoAlternateASPActive [
	^ self isStatusOther and: [ self statusInfo = self class infoAlternateASPActive ]
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isInfoAsActive [
	^ self statusInfo = self class infoAsActive
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isInfoAsInactive [
	^ self statusInfo = self class infoAsInactive
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isInfoAsPending [
	^ self statusInfo = self class infoAsPending
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isInfoInsufficientASPResourcesActiveInAS [
	^ self isStatusOther and: [ self statusInfo = self class infoInsufficientASPResourcesActiveInAS ]
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isInfoReserved [
	^ self statusInfo = self class infoReserved
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isStatusApplicationServerStateChange [
	^ self statusType = self class statusApplicationServerStateChange
]

{ #category : #testing }
M3UATagMGMTNotifyStatus >> isStatusOther [
	^ self statusType = self class statusOther
]

{ #category : #access }
M3UATagMGMTNotifyStatus >> statusInfo [
	^ (self data copyFrom: 3 to: 4) asInteger
]

{ #category : #access }
M3UATagMGMTNotifyStatus >> statusType [
	^ (self data copyFrom: 1 to: 2) asInteger
]
