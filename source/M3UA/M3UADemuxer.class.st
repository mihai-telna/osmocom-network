Class {
	#name : #M3UADemuxer,
	#superclass : #M3UAEntity,
	#instVars : [
		'socket'
	],
	#category : #'M3UA-Communication'
}

{ #category : #creation }
M3UADemuxer class >> initOn: aSocket [
	^ self new
		socket: aSocket;
		yourself
]

{ #category : #reading }
M3UADemuxer >> next [
	"
	Header : 2 lines of 4 bytes
	0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |    Version    |   Reserved    | Message Class | Message Type  |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                        Message Length                         |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      \                                                               \
      /   "

	| header version messageClass messageType size data |
	header := socket next: 8.

	"first header line"
	version := header at: 1.
	messageClass := header at: 3.
	messageType := header at: 4.

	"second header line"
	size := header at: 5.
	size := (size bitShift: 8) + (header at: 6).
	size := (size bitShift: 8) + (header at: 7).
	size := (size bitShift: 8) + (header at: 8).
	data := socket next: size - 8.
	^ Array with: M3UAConstants applicationM3UA with: header , data
]

{ #category : #accessing }
M3UADemuxer >> socket: aSocket [
	socket := aSocket
]
