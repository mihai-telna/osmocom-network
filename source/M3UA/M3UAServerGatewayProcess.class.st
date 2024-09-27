Class {
	#name : #M3UAServerGatewayProcess,
	#superclass : #M3UALogicalEntityProcess,
	#category : #'M3UA-Core'
}

{ #category : #'error handling' }
M3UAServerGatewayProcess >> handleChannelClosedForDelegate: aM3UAOsmoMessageReadDelegate [
	| remoteAspInFailure |
	super handleChannelClosedForDelegate: aM3UAOsmoMessageReadDelegate.
	remoteAspInFailure := self host
		remoteAspMatchingChannel: aM3UAOsmoMessageReadDelegate channelNumber
		ofSGP: aM3UAOsmoMessageReadDelegate logicalProcess
]

{ #category : #access }
M3UAServerGatewayProcess >> sctpConnected [
	"The SCTP connection has been established"
]

{ #category : #access }
M3UAServerGatewayProcess >> sctpEstablish [
	"The SCTP connection has been established"
]
