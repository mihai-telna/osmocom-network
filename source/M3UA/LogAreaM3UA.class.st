"
I am the debug area for M3UA messages
"
Class {
	#name : #LogAreaM3UA,
	#superclass : #LogArea,
	#category : #'M3UA-Core'
}

{ #category : #accessing }
LogAreaM3UA class >> areaDescription [
	^'MTP3 User Adaption'

]

{ #category : #accessing }
LogAreaM3UA class >> areaName [
	^#m3ua

]

{ #category : #creation }
LogAreaM3UA class >> default [
	^(self new)
	    enabled: true;
	    minLevel: LogLevel debug;
	    yourself

]
