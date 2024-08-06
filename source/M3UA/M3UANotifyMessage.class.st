Class {
	#name : #M3UANotifyMessage,
	#superclass : #M3UAMGMTMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UANotifyMessage class >> messageTag [
	^M3UAConstants typeMgmtNTFY

]

{ #category : #'m3ua-asp-dispatch' }
M3UANotifyMessage >> dispatchOnAsp: anAsp [
	anAsp handleNotify: self
]
