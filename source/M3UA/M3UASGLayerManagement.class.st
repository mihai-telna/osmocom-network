Class {
	#name : #M3UASGLayerManagement,
	#superclass : #M3UALayerManagement,
	#category : #'M3UA-Core'
}

{ #category : #'Primitives MTP-STATUS' }
M3UASGLayerManagement >> noticesCongestionForRoutingContextId: anIntegerRC networkAppearance: anIntegerNA affectedPcs: aCollectionOfApc forLogicalProcess: aLogicalProcess [
	"Discovered At SGP"

	self
		performMTPStatusIndicationPrimitiveWithRoutingContextId: anIntegerRC
		networkAppearance: anIntegerNA
		affectedPcs: aCollectionOfApc
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitives MTP-RESUME' }
M3UASGLayerManagement >> noticesDestinationAvailableForRoutingContextId: anIntegerRC networkAppearance: anIntegerNA affectedPcs: aCollectionOfApc forLogicalProcess: aLogicalProcess [
	"Discovered At SGP"

	self
		performMTPResumeIndicationPrimitiveWithRoutingContextId: anIntegerRC
		networkAppearance: anIntegerNA
		affectedPcs: aCollectionOfApc
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitives MTP-PAUSE' }
M3UASGLayerManagement >> performMTPPauseIndicationPrimitiveWithRoutingContextId: anIntegerRC networkAppearance: anIntegerNA affectedPcs: aCollectionOfApc toLogicalProcess: aLogicalProcess [
	"Ask the ServerGateway to send a DUNA message (Destination Unavailable)
	Direction Network -> SG
	Cf paragraph 5.5.2.3.1."

	self logicalEntity
		createAndSendDUNAMessageForAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: (OrderedCollection with: anIntegerRC)
		infoString: nil
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitives MTP-RESUME' }
M3UASGLayerManagement >> performMTPResumeIndicationPrimitiveWithRoutingContextId: anIntegerRC networkAppearance: anIntegerNA affectedPcs: aCollectionOfApc toLogicalProcess: aLogicalProcess [
	"Ask the ServerGateway to send a DAVA message (Destination available)
	Direction Network -> SG
	Cf paragraph 5.5.2.3.2."

	self logicalEntity
		createAndSendDAVAMessageForAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: (OrderedCollection with: anIntegerRC)
		infoString: nil
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitives MTP-STATUS' }
M3UASGLayerManagement >> performMTPStatusIndicationPrimitiveWithAffectedPointCode: anIntegerApc mtp3User: anIntegerMTP3User routingContextId: anIntegerRC networkAppearance: anIntegerNA toLogicalProcess: aLogicalProcess [
	"Ask the ServerGateway to send a DUPU message
	Direction Network -> SG
	Cf paragraph 5.5.2.3.4."

	self logicalEntity
		createAndSendDUPUMessageForAffectedPointCode: anIntegerApc
		mtp3User: anIntegerMTP3User
		networkAppearance: anIntegerNA
		routingContextsIds: (OrderedCollection with: anIntegerRC)
		infoString: nil
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitives MTP-STATUS' }
M3UASGLayerManagement >> performMTPStatusIndicationPrimitiveWithRoutingContextId: anIntegerRC networkAppearance: anIntegerNA affectedPcs: aCollectionOfApc toLogicalProcess: aLogicalProcess [
	"Ask the ServerGateway to send a SCON message
	Direction Network -> SG
	Cf paragraph 5.5.2.3.3."

	self logicalEntity
		createAndSendSCONMessageForAffectedPointCodes: aCollectionOfApc
		networkAppearance: anIntegerNA
		routingContextsIds: (OrderedCollection with: anIntegerRC)
		infoString: nil
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitive MTP-TRANSFER' }
M3UASGLayerManagement >> performMTPTransferIndicationPrimitiveFor: aPayloadData toLogicalProcess: aLogicalProcess [
	"Cf paragraph 5.5.2.2.
	Ask the SGP to send a aPayloadData message"

	logicalEntity
		createAndSendM3UAPayloadDataMessageFor: aPayloadData
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitive MTP-TRANSFER' }
M3UASGLayerManagement >> performMTPTransferRequestPrimitiveWith: aPayloadData [
	"Cf paragraph 5.5.2.1.
	Direction SGP -> Network"

	self flag: #todo
]

{ #category : #'Primitives MTP-PAUSE' }
M3UASGLayerManagement >> receivesDestinationUnavailableForRoutingContextId: anIntegerRC networkAppearance: anIntegerNA affectedPcs: aCollectionOfApc forLogicalProcess: aLogicalProcess [
	"Direction Network -> SGP"

	self
		performMTPPauseIndicationPrimitiveWithRoutingContextId: anIntegerRC
		networkAppearance: anIntegerNA
		affectedPcs: aCollectionOfApc
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitive MTP-TRANSFER' }
M3UASGLayerManagement >> receivesTransfer: aPayloadData forLogicalProcess: aLogicalProcess [
	"Direction Network -> SGP"

	self
		performMTPTransferIndicationPrimitiveFor: aPayloadData
		toLogicalProcess: aLogicalProcess
]
