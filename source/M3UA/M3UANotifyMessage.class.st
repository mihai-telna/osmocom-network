"
M3UANotifyMessage can be sent by SGP or ASP
"
Class {
	#name : #M3UANotifyMessage,
	#superclass : #M3UAMGMTMessage,
	#category : #'M3UA-Messages'
}

{ #category : #creation }
M3UANotifyMessage class >> messageTag [
	^M3UAConstants typeMgmtNTFY

]

{ #category : #access }
M3UANotifyMessage >> aspIdentifier [
	^ (self findTag: M3UAConstants tagASPIdentifier ifAbsent: [ ^ nil ])
		data asArray
]

{ #category : #'m3ua-asp-dispatch' }
M3UANotifyMessage >> dispatchOnLogicalProcess: aLogicalEntityProcess [
	aLogicalEntityProcess handleNotify: self
]
