Class {
	#name : #M3UASGMock,
	#superclass : #Object,
	#instVars : [
		'asp',
		'networkService',
		'lastMsgReceived'
	],
	#category : #'M3UA-Tests'
}

{ #category : #'instance creation' }
M3UASGMock class >> networkService: aSCTPNetworkService [
	^ self new
		networkService: aSCTPNetworkService;
		asp: (M3UAApplicationServerProcess initWith: aSCTPNetworkService);
		yourself
]

{ #category : #accessing }
M3UASGMock >> asp [
	^ asp
]

{ #category : #accessing }
M3UASGMock >> asp: anObject [
	asp := anObject
]

{ #category : #dispatch }
M3UASGMock >> dispatchData: aData [
	| msg |
	msg := M3UAMSG parseToClassFromStream: aData.
	msg dispatchOnAsp: self asp.
	
	lastMsgReceived := msg
]

{ #category : #dispatch }
M3UASGMock >> handleAspActive: aMsg [
	| ack |
	ack := M3UAASPActiveAckMessage newMessage.
	networkService sendToAsp: ack toMessage asByteArray
]

{ #category : #dispatch }
M3UASGMock >> handleAspDown: aMsg [
	| ack |
	ack := M3UAASPDownAckMessage newMessage.
	networkService sendToAsp: ack toMessage asByteArray
]

{ #category : #dispatch }
M3UASGMock >> handleAspInactive: aMsg [
	| ack |
	ack := M3UAASPInactiveAckMessage newMessage.
	networkService sendToAsp: ack toMessage asByteArray
]

{ #category : #dispatch }
M3UASGMock >> handleAspUp: aMsg [
	| ack |
	ack := M3UAASPUpAckMessage newMessage.
	networkService sendToAsp: ack toMessage asByteArray
]

{ #category : #testing }
M3UASGMock >> isServerGateway [
	"let it simple"

	^ false
]

{ #category : #accessing }
M3UASGMock >> lastMsgReceived [
	^ lastMsgReceived
]

{ #category : #access }
M3UASGMock >> name [
	^ 'SG Mock'
]

{ #category : #accessing }
M3UASGMock >> networkService [
	^ networkService
]

{ #category : #accessing }
M3UASGMock >> networkService: anObject [
	networkService := anObject.
	networkService
		onSctpData: [ :routingKey :originAsp :pid :data | self dispatchData: data ]
]

{ #category : #access }
M3UASGMock >> trafficModeTypeForASP: anASP [
	^ 2
]
