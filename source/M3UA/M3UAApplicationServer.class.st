Class {
	#name : #M3UAApplicationServer,
	#superclass : #M3UALogicalEntity,
	#instVars : [
		'asStateMachine',
		'currentAsp',
		'lastPayloadReceived',
		'dictRoutingContextRoutingKey'
	],
	#category : #'M3UA-Core'
}

{ #category : #routingContexts }
M3UAApplicationServer >> addRoutingKey: aM3UARoutingKey forRoutingContext: anInteger [
	dictRoutingContextRoutingKey at: anInteger put: aM3UARoutingKey
]

{ #category : #accessing }
M3UAApplicationServer >> asStateMachine [
	^ asStateMachine
]

{ #category : #'process searching' }
M3UAApplicationServer >> chooseCurrentAsp [
	| indexCurrent |
	self trafficModeName = 'Loadshare'
		ifTrue: [ indexCurrent := currentAsp
				ifNil: [ 0 ]
				ifNotNil: [ self registeredAsps indexOf: currentAsp ].
			currentAsp := self registeredAsps
				at:
					(indexCurrent = self registeredAsps size
						ifTrue: [ 1 ]
						ifFalse: [ indexCurrent + 1 ]) ]
		ifFalse: [ self flag: #todo.
			currentAsp := self registeredAsps first ].
	^ currentAsp
]

{ #category : #'process searching' }
M3UAApplicationServer >> chooseProcess [
	^ self chooseCurrentAsp
]

{ #category : #accessing }
M3UAApplicationServer >> dictRoutingContextRoutingKey [
	^ dictRoutingContextRoutingKey
]

{ #category : #'Primitives-LayerManagement-RKM' }
M3UAApplicationServer >> handleDeregistrationResponse: aM3UADeregistrationResponseMessage [
	self flag: #todo
]

{ #category : #'Primitives-LayerManagement-RKM' }
M3UAApplicationServer >> handleRegistrationResponse: aM3UARegistrationResponseMessage [
	self flag: #todo
]

{ #category : #routingContexts }
M3UAApplicationServer >> handledRoutingContexts [
	^ dictRoutingContextRoutingKey keys
]

{ #category : #initialization }
M3UAApplicationServer >> initialize [
	super initialize.
	asStateMachine := M3UAAsStateMachine new.
	asStateMachine aspStateMachines: OrderedCollection new.
	dictRoutingContextRoutingKey := Dictionary new
]

{ #category : #testing }
M3UAApplicationServer >> isServerGateway [
	^ false
]

{ #category : #accessing }
M3UAApplicationServer >> lastPayloadReceived [
	^ lastPayloadReceived
]

{ #category : #routing }
M3UAApplicationServer >> networkService: aM3UANetworkService [
	"To put in class RHCentralForM3UA after tests validation.
	The calls to the method #signalUnitData:  should be done only for Transfer messages"

	self flag: #todo.
	aM3UANetworkService
		onUnitData:
			[ :data :opc :dpc :priority | self routeM3UAMData: data fromOpc: opc dpc: dpc ]
]

{ #category : #initialization }
M3UAApplicationServer >> registerASP: aM3UAApplicationServerProcess [
	aM3UAApplicationServerProcess host: self.
	
	"Add to the ASP list"
	self registeredAsps addLast: aM3UAApplicationServerProcess.
			
	"Link states machines"
	asStateMachine aspStateMachines
		addLast: aM3UAApplicationServerProcess aspStateMachine.
	asStateMachine
		handleAnnouncementFor: aM3UAApplicationServerProcess aspStateMachine
]

{ #category : #access }
M3UAApplicationServer >> registeredAsps [
	^ registeredProcesses
]

{ #category : #routingContexts }
M3UAApplicationServer >> removeRoutingKeyWithRoutingContext: anInteger [
	dictRoutingContextRoutingKey removeKey: anInteger ifAbsent: [  ]
]

{ #category : #routing }
M3UAApplicationServer >> routeM3UAMData: aByteArray fromOpc: opc dpc: dpc [
	"To do : use a M3URouter to pass the message to the RHCentral"

	lastPayloadReceived := aByteArray
]

{ #category : #sending }
M3UAApplicationServer >> targetPeerForASP: oneOfMyAsp [
	^ configuration targetPeerForASP: oneOfMyAsp
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> trafficModeName [
	"Note : Round-Robin is a sub-mode of Loadshare"

	| trafficModeType |
	(trafficModeType := configuration trafficModeType) = 1
		ifTrue: [ ^ 'Override' ].
	trafficModeType = 2
		ifTrue: [ ^ 'Loadshare' ].
	trafficModeType = 3
		ifTrue: [ ^ 'Broadcast' ]
]

{ #category : #'traffic mode' }
M3UAApplicationServer >> trafficModeType [
	"Note : Round-Robin is a sub-mode of Loadshare"

	^ configuration trafficModeType
]
