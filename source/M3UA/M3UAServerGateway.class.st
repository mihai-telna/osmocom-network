Class {
	#name : #M3UAServerGateway,
	#superclass : #M3UAApplicationServer,
	#instVars : [
		'dicoRoutingContextActivities'
	],
	#category : #'M3UA-Core'
}

{ #category : #access }
M3UAServerGateway >> addNewRemoteASPWithIdentifier: aByteArray name: aString [
	| newAsp |
	newAsp := M3UAApplicationServerProcess new.
	newAsp identifier: aByteArray.
	newAsp name: aString.
	self addRemotePeer: newAsp forAsp: self chooseCurrentAsp
]

{ #category : #accessing }
M3UAServerGateway >> dicoRoutingContextActivities [
	^ dicoRoutingContextActivities
]

{ #category : #accessing }
M3UAServerGateway >> dicoRoutingContextActivities: anObject [
	dicoRoutingContextActivities := anObject
]

{ #category : #'handling-messages-ASP' }
M3UAServerGateway >> handleAspUp: aMsgUp [
	| tagIdentifier remoteAsp tagInfoString string |
	(super handleAspUp: aMsgUp)
		ifFalse: [ ^ false ].

	"Is there an ASP identifier ?"
	tagIdentifier := aMsgUp
		findTag: M3UAConstants tagASPIdentifier
		ifAbsent: [ ^ self ].

	"Do we know this ASP ?"
	(remoteAsp := self findRemoteAspWithIdentifier: tagIdentifier data)
		ifNil: [ tagInfoString := aMsgUp
				findTag: M3UAConstants tagINFOString
				ifAbsent: [ ^ self ].
			string := tagInfoString asString.
			name := string copyFrom: (string indexOf: $:) + 1 to: string size.

			"we have to store the canal where the message comes from
			we can't rely on the name"
			self flag: #todo.
			self addNewRemoteASPWithIdentifier: tagIdentifier data name: name.
			^ self ].

	"Is there some RoutingContext inactive for this ASP ?
	If yes, we send a notify message for each inactive RoutingContext"
	remoteAsp handledRoutingContexts
		do: [ :anIntegerRC | 
			(dicoRoutingContextActivities at: anIntegerRC ifAbsent: [ false ])
				ifFalse:
					[ self notifyMessageInactiveASP: remoteAsp routingContext: anIntegerRC ] ]
]

{ #category : #initialization }
M3UAServerGateway >> initialize [
	super initialize.
	dicoRoutingContextActivities := Dictionary new
]

{ #category : #testing }
M3UAServerGateway >> isServerGateway [
	^ true
]

{ #category : #'handling-messages-ASP' }
M3UAServerGateway >> updateRemoteAsp: aRemoteAsp withMessageActive: aMsgActive [
	| remoteAsp tagRoutingContext routingContext tagIdentifier |
	"Find the ASP"
	(tagIdentifier := aMsgActive findTag: M3UAConstants tagASPIdentifier)
		ifNil: [ remoteAsp := dicoPeers values
				detect: [ :asp | asp name = aRemoteAsp name ]
				ifNone: [ nil ] ]
		ifNotNil: [ remoteAsp := self findRemoteAspWithIdentifier: tagIdentifier data ].
	remoteAsp ifNil: [ ^ self ].

	"routing context"
	tagRoutingContext := aMsgActive
		findTag: M3UAConstants tagRoutingContext
		ifAbsent: [ ^ self ].
	routingContext := tagRoutingContext routingContext.

	"log"
	self
		logDebug:
			self class name , ' (' , self name , ') : ROUTING CONTEXT '
				, routingContext printString , ' of ' , remoteAsp name
				, ' is now acive'
		area: #m3ua.

	"Put the Routing Context as active,
	and send a notify message"
	dicoRoutingContextActivities at: routingContext put: true.
	remoteAsp handledRoutingContexts addIfNotPresent: routingContext.
	self notifyMessageActiveASP: remoteAsp routingContext: routingContext
]
