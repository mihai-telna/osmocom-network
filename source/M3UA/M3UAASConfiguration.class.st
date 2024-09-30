"
A M3UAASConfiguration object is used by a M3UAApplicationServer objet and the corresponding M3UALayerManagement,
 to define several parameters used for the global network knowledge, the routing rules, the traffic mode for the ASP, ...


Instance Variables
	- peers : <OrderedCollection> 
	A peer is a remote ASP belonging to a SG, known by a name and an identifier.
	The peers are all ASP for one or several SG that the AS can potentially talk to.
	This is a static list (we don't handle here if one peer is down)
	
	- dictRemotePeersByASP :		<Dictionary>
   This defines which ASP will serve which SG.
	One key is is one ASP of the AS and one Value is a remote SGP belonging to a SG.
	This dictionary can be dynamic, the Layer Management can desallocate/reallocate traffic by modifying it



"
Class {
	#name : #M3UAASConfiguration,
	#superclass : #M3UALogicalEntityConfiguration,
	#instVars : [
		'peers',
		'dictRemotePeersByASP',
		'trafficModeType',
		'stateMachineRequiredNumberOfAsps',
		'stateMachineRecoveryTimerDelayMax'
	],
	#category : #'M3UA-Core'
}

{ #category : #access }
M3UAASConfiguration class >> defaultTrafficModeType [
	^ 2
]

{ #category : #'instance creation' }
M3UAASConfiguration class >> onApplicationServer: anAS requiredNumberOfAsps: anInteger1 recoveryTimerDelayMax: anInteger2 [
	| asConfiguration |
	asConfiguration := self new.
	anAS configuration: asConfiguration.
	asConfiguration stateMachineRequiredNumberOfAsps: anInteger1.
	asConfiguration stateMachineRecoveryTimerDelayMax: anInteger2.
	anAS asStateMachine requiredNumberOfAsps: anInteger1.
	anAS asStateMachine recoveryTimerDelayMax: anInteger2.
	^ asConfiguration
]

{ #category : #'remote peers' }
M3UAASConfiguration >> addRemoteTargetPeer: aRemoteAsp [
	"Add a remote ASP to the list of remote peers"

	peers addLast: aRemoteAsp
]

{ #category : #'remote peers' }
M3UAASConfiguration >> addRemoteTargetPeer: aRemoteAsp forASP: oneOfMyAsp [
	"Add a remote ASP with who oneOfMyAsp wants to talk to, through a SCTP connection"
	
	^ dictRemotePeersByASP at: oneOfMyAsp put: aRemoteAsp
]

{ #category : #initialization }
M3UAASConfiguration >> initialize [
	super initialize.
	peers := OrderedCollection new.
	trafficModeType := self class defaultTrafficModeType.
	dictRemotePeersByASP := Dictionary new
]

{ #category : #'remote peers' }
M3UAASConfiguration >> peerNamed: aString [
	"Return the remote ASP named aString with who oneOfMyAsp wants to talk to, 
	through a SCTP connection"

	^ peers detect: [ :asp | asp name = aString ] ifNone: [ nil ]
]

{ #category : #accessing }
M3UAASConfiguration >> stateMachineRecoveryTimerDelayMax [
	^ stateMachineRecoveryTimerDelayMax
]

{ #category : #accessing }
M3UAASConfiguration >> stateMachineRecoveryTimerDelayMax: anObject [
	stateMachineRecoveryTimerDelayMax := anObject
]

{ #category : #accessing }
M3UAASConfiguration >> stateMachineRequiredNumberOfAsps [
	^ stateMachineRequiredNumberOfAsps
]

{ #category : #accessing }
M3UAASConfiguration >> stateMachineRequiredNumberOfAsps: anObject [
	stateMachineRequiredNumberOfAsps := anObject
]

{ #category : #'remote peers' }
M3UAASConfiguration >> targetPeerForASP: oneOfMyAsp [
	"Return the remote ASP with who oneOfMyAsp wants to talk to, 
	through a SCTP connection"

	^ dictRemotePeersByASP at: oneOfMyAsp ifAbsent: [ nil ]
]

{ #category : #accessing }
M3UAASConfiguration >> trafficModeType [
	^ trafficModeType
]

{ #category : #accessing }
M3UAASConfiguration >> trafficModeType: anObject [
	trafficModeType := anObject
]
