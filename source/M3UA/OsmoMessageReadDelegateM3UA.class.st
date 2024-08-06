Class {
	#name : #OsmoMessageReadDelegateM3UA,
	#superclass : #OsmoMessageReadDelegate,
	#instVars : [
		'on_data',
		'asp',
		'peerIdentifier',
		'demuxer',
		'muxer',
		'dispatcher',
		'connect_block',
		'numberForServer',
		'm3uaConnection'
	],
	#category : #'M3UA-Communication'
}

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> asp [
	^ asp
]

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> asp: anObject [
	asp := anObject
]

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> dispatcher [
	^ dispatcher
]

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> m3uaConnection [
	^ m3uaConnection
]

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> m3uaConnection: anObject [
	m3uaConnection := anObject
]

{ #category : #writing }
OsmoMessageReadDelegateM3UA >> nextPut: aData with: aConstant [
	muxer nextPut: aData with: aConstant
]

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> numberForServer [
	^ numberForServer
]

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> numberForServer: anObject [
	numberForServer := anObject
]

{ #category : #signalling }
OsmoMessageReadDelegateM3UA >> onUnitData: aBlock [
	on_data := aBlock
]

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> peerIdentifier [
	^ peerIdentifier
]

{ #category : #accessing }
OsmoMessageReadDelegateM3UA >> peerIdentifier: anObject [
	peerIdentifier := anObject
]

{ #category : #signalling }
OsmoMessageReadDelegateM3UA >> signalUnitData: aMsg fromAS: anApplicationServer from: anAspOrigin [
	"Inform the upper layer about data"

	on_data
		ifNotNil: [ on_data
				cull: anApplicationServer name
				cull: anAspOrigin identifier
				cull: 2
				cull: aMsg toMessage asByteArray ]
]

{ #category : #writing }
OsmoMessageReadDelegateM3UA >> write: aMsg [
	self flag: #todo
]
