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
	super logDebug: ' (' , self logicalProcess name , ') : ' , aString
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

	"debug"
	self
		logDebug:
			'#signalUnitData received from ' , opc printString , ' to '
				, dpc printString.
	"end debug"
	
	on_data
		ifNotNil: [ on_data
				cull: aByteArray
				cull: opc
				cull: dpc
				cull: priority ]
]

{ #category : #connect }
M3UANetworkService >> start [

	"debug"
	self logDebug: ' started.'.
	"end debug"
	
	on_connect_block value
]

{ #category : #connect }
M3UANetworkService >> stop [

	"debug"
	self logDebug: ' stopped.'.
	"end debug"

	on_release_block value
]
