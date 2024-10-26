Class {
	#name : #M3UATagCongestionIndications,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagCongestionIndications class >> nrValue [
	^ M3UAConstants tagCongestionIndications
]

{ #category : #access }
M3UATagCongestionIndications >> congestionLevelField [
	^ (self data copyFrom: 1 to: 4) asInteger
]

{ #category : #testing }
M3UATagCongestionIndications >> isCongestionLevel1 [
	^ self congestionLevelField = 1
]

{ #category : #testing }
M3UATagCongestionIndications >> isCongestionLevel2 [
	^ self congestionLevelField = 2
]

{ #category : #testing }
M3UATagCongestionIndications >> isCongestionLevel3 [
	^ self congestionLevelField = 3
]

{ #category : #testing }
M3UATagCongestionIndications >> isNoCongestionOrUndefined [
	^ self congestionLevelField = 0
]
