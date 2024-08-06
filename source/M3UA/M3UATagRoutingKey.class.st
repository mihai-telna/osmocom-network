Class {
	#name : #M3UATagRoutingKey,
	#superclass : #M3UATag,
	#category : #'M3UA-Tags'
}

{ #category : #access }
M3UATagRoutingKey class >> nrValue [
	^ M3UAConstants tagRoutingKey
]

{ #category : #access }
M3UATagRoutingKey >> routingContext [
	self flag: #todo
]
