Class {
	#name : #SCCPNetworkServiceM3UAOsmoDirectServer,
	#superclass : #SCCPNetworkServiceM3UAOsmoDirect,
	#instVars : [
		'm3uaConnectionsServer'
	],
	#category : #'M3UA-Communication'
}

{ #category : #dispatching }
SCCPNetworkServiceM3UAOsmoDirectServer >> delegateForAsp: originAspIdentifier peer: aRemoteAspIdentifier [
	m3uaConnectionsServer dicoDelegates
		keysAndValuesDo: [ :asp :listDelegates | 
			asp identifier = originAspIdentifier
				ifTrue: [ listDelegates
						do: [ :aDelegate | 
							aDelegate peerIdentifier = aRemoteAspIdentifier
								ifTrue: [ ^ aDelegate ] ] ] ].
	^ nil
]

{ #category : #initialization }
SCCPNetworkServiceM3UAOsmoDirectServer >> initConnectionsServer [
	applicationServer registeredAsps
		do: [ :asp | 
			| listDelegates |
			listDelegates := OrderedCollection new.
			asp peersIdentifiers
				do: [ :ident | 
					| aDelegate |
					aDelegate := OsmoMessageReadDelegateM3UA new
						asp: asp;
						peerIdentifier: ident;
						yourself.
					aDelegate
						onUnitData:
							[ :asRoutingKey :originAspIdentifier :ppid :data | 
							ppid = 2
								ifFalse: [ ^ self
										logNotice: 'M3UAApplicationServerProcess expecting PPID 2.'
										area: #m3ua ].
							aDelegate asp
								dispatchData: data
								originAspIdentifier: originAspIdentifier ].
					listDelegates addLast: aDelegate ].
			m3uaConnectionsServer addDelegates: listDelegates forAsp: asp ]
]

{ #category : #initialization }
SCCPNetworkServiceM3UAOsmoDirectServer >> initialize [
	super initialize.
	m3uaConnectionsServer := OsmoMessageServerM3UA new
		networkService: self
]

{ #category : #accessing }
SCCPNetworkServiceM3UAOsmoDirectServer >> m3uaConnectionsServer [
	^ m3uaConnectionsServer
]
