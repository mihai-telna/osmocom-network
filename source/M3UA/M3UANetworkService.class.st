Class {
	#name : #M3UANetworkService,
	#superclass : #M3UAEntity,
	#instVars : [
		'on_connect_block',
		'on_release_block',
		'on_data',
		'logicalProcess'
	],
	#category : #'M3UA-Communication'
}

{ #category : #'instance creation' }
M3UANetworkService class >> on: anM3UAApplicationServer [
	^ self new
		as: anM3UAApplicationServer;
		yourself
]

{ #category : #debug }
M3UANetworkService >> logDebug: aString [
	self
		logDebug: self class name , '(' , self logicalProcess name , ') : ' , aString
		area: #m3ua
]

{ #category : #accessing }
M3UANetworkService >> logicalProcess [
	^ logicalProcess
]

{ #category : #accessing }
M3UANetworkService >> logicalProcess: anApplicationServerProcess [
	logicalProcess := anApplicationServerProcess
]

{ #category : #sctp }
M3UANetworkService >> onSctpConnect: aBlock [
	on_connect_block := aBlock
]

{ #category : #sctp }
M3UANetworkService >> onSctpRelease: aBlock [
	on_release_block := aBlock
]

{ #category : #registration }
M3UANetworkService >> onUnitData: aBlock [
	"Reports that a data has arrived"

	on_data := aBlock
]

{ #category : #callbacks }
M3UANetworkService >> signalUnitData: aByteArray fromOpc: opc toDpc: dpc priority: priority [
	"Inform the upper layer about data"

	self
		logDebug:
			self class name , '(' , self logicalProcess name , ') : '
				, '#signalUnitData received from ' , opc printString , ' to '
				, dpc printString
		area: #m3ua.
	on_data
		ifNotNil: [ on_data
				cull: aByteArray
				cull: opc
				cull: dpc
				cull: priority ]
]

{ #category : #connect }
M3UANetworkService >> start [
	self logDebug: ' started.'.
	on_connect_block value
]

{ #category : #connect }
M3UANetworkService >> stop [
	self
		logDebug: self class name , ' stopped.'
		area: #m3ua.
	on_release_block value
]
