Class {
	#name : #M3UAHandler,
	#superclass : #Object,
	#instVars : [
		'm3uaConnection'
	],
	#category : #'M3UA-Communication'
}

{ #category : #accessing }
M3UAHandler >> m3uaConnection [
	^ m3uaConnection
]

{ #category : #accessing }
M3UAHandler >> m3uaConnection: anObject [
	m3uaConnection := anObject
]

{ #category : #dispatching }
M3UAHandler >> receiveM3uaMessage: aByteArray delegate: aOsmoMessageReadDelegateM3UA [
	"Main Entry for handling M3UA messages"

	"--- debug ---"
	"--- end debug ---"
	
	m3uaConnection
		receiveM3uaMessage: aByteArray
		delegate: aOsmoMessageReadDelegateM3UA
]

{ #category : #'as yet unclassified' }
M3UAHandler >> registerApplicationM3uaOn: aM3UADispatcher [
	"Registration process is sent at connexion time.
	Adds the adequate handler to the dispatcher."

	"--- debug ---"
	"--- end debug ---"
	
	aM3UADispatcher
		addHandler: M3UAConstants applicationM3UA
		on: self
		with: #receiveM3uaMessage:delegate:
]
