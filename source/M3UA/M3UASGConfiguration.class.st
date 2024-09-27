"
Instance Variables

	- dictRemotePeersBySGP :		<Dictionary>
   This defines which SGP will serve which ASP.
	One key is is one SGP of the SG and one Value is a collection of remote ASPs belonging to a AS.
	This dictionary can be dynamic, the Layer Management can desallocate/reallocate traffic by modifying it

"
Class {
	#name : #M3UASGConfiguration,
	#superclass : #M3UALogicalEntityConfiguration,
	#instVars : [
		'dictRemotePeersBySGP'
	],
	#category : #'M3UA-Core'
}

{ #category : #'instance creation' }
M3UASGConfiguration class >> onServerGateway: aSG [
	| sgConfiguration |
	sgConfiguration := self new.
	aSG configuration: sgConfiguration.
	^ sgConfiguration
]

{ #category : #'remote peers' }
M3UASGConfiguration >> addRemoteTargetPeer: aRemoteAsp forSGP: oneOfMySgp [
	"Add a remote ASP with who oneOfMySgp wants to talk to, through a SCTP connection"

	| list |
	list := dictRemotePeersBySGP
		at: oneOfMySgp
		ifAbsentPut: [ OrderedCollection new ].
	list addLast: aRemoteAsp
]

{ #category : #'remote peers' }
M3UASGConfiguration >> findRemoteAspWithIdentifier: aByteArray [
	"We are looking for a remote ASP known in our matching table SGP/ASPs"

	
	dictRemotePeersBySGP
		keysAndValuesDo: [ :localAsp :aCollectionOfRemoteAsp | 
			aCollectionOfRemoteAsp
				do: [ :aRemoteAsp | 
					aRemoteAsp identifier = aByteArray asArray
						ifTrue: [ ^ aRemoteAsp ] ] ].
	^ nil
]

{ #category : #initialization }
M3UASGConfiguration >> initialize [
	super initialize.
	dictRemotePeersBySGP := Dictionary new
]
