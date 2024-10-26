Class {
	#name : #M3UAServerGatewayProcess,
	#superclass : #M3UALogicalEntityProcess,
	#category : #'M3UA-Core'
}

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAServerGatewayProcess >> handleAspHeartbeatAck: aM3UAASPHeartbeatAckMessage [

]

{ #category : #'error handling' }
M3UAServerGatewayProcess >> handleChannelClosedForDelegate: aM3UAOsmoMessageReadDelegate [
	| remoteAspInFailure |
	super handleChannelClosedForDelegate: aM3UAOsmoMessageReadDelegate.
	remoteAspInFailure := self host
		remoteAspMatchingChannel: aM3UAOsmoMessageReadDelegate channelNumber
		ofSGP: aM3UAOsmoMessageReadDelegate logicalProcess
]

{ #category : #private }
M3UAServerGatewayProcess >> handleError: aM3UAErrorMessage [
]

{ #category : #'Primitives-LayerManagement-ASP' }
M3UAServerGatewayProcess >> handleNotify: aM3UANotifyMessage [
]

{ #category : #access }
M3UAServerGatewayProcess >> sctpConnected [
	"The SCTP connection has been established"
]

{ #category : #access }
M3UAServerGatewayProcess >> sctpEstablish [
	"The SCTP connection has been established"
]
