Class {
	#name : #SCCPNetworkServiceM3UAOsmoBase,
	#superclass : #SCCPNetworkServiceM3UA,
	#instVars : [
		'conn',
		'rxCounter'
	],
	#category : #'M3UA-Communication'
}

{ #category : #internal }
SCCPNetworkServiceM3UAOsmoBase >> doSend: aMessage to: aToPoc from: aFromPoc [
	conn nextPut: aMessage with: IPAConstants protocolSCCP
]
