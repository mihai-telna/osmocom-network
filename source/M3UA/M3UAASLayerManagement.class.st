Class {
	#name : #M3UAASLayerManagement,
	#superclass : #M3UALayerManagement,
	#category : #'M3UA-Core'
}

{ #category : #'Primitives MTP-STATUS' }
M3UAASLayerManagement >> performMTPCongestionStatusIndicationPrimitiveForAffectedPointCodes: aCollectionOfIntegerApc routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	"Direction ASP -> Network
	Cf paragraph 5.5.2.3.3."

	self flag: #todo
]

{ #category : #'Primitives MTP-PAUSE' }
M3UAASLayerManagement >> performMTPPauseIndicationPrimitiveForAffectedPointCodes: aCollectionOfIntegerApc routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	"Direction ASP -> Network
	Cf paragraph 5.5.2.3.1."

	self flag: #todo
]

{ #category : #'Primitives MTP-RESUME' }
M3UAASLayerManagement >> performMTPResumeIndicationPrimitiveForAffectedPointCodes: aCollectionOfIntegerApc routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	"Direction ASP -> Network
	Cf paragraph 5.5.2.3.2."

	self flag: #todo
]

{ #category : #'Primitive MTP-TRANSFER' }
M3UAASLayerManagement >> performMTPTransferIndicationPrimitiveWith: aPayloadData [
	"Cf paragraph 5.5.1.1.2.
	Direction ASP -> Network"

	self flag: #todo
]

{ #category : #'Primitive MTP-TRANSFER' }
M3UAASLayerManagement >> performMTPTransferRequestPrimitiveFor: aPayloadData toLogicalProcess: aLogicalProcess [
	"Ask the AS to create of a M3UAPayloadDataMessage.
	Cf paragraph 5.5.1.1.1."

	logicalEntity
		createAndSendM3UAPayloadDataMessageFor: aPayloadData
		toLogicalProcess: aLogicalProcess
]

{ #category : #'Primitives MTP-STATUS' }
M3UAASLayerManagement >> performMTPUserPartUnavailableStatusIndicationPrimitiveForAffectedPointCode: anIntegerApc mtp3User: anIntegerMtp3User routingContextsIds: aCollectionOfIntegerRC networkAppareance: anIntegerNA [
	"Direction ASP -> Network
	Cf paragraph 5.5.2.3.4."

	self flag: #todo
]

{ #category : #'Primitive MTP-TRANSFER' }
M3UAASLayerManagement >> receivesTransfer: aPayloadData forLogicalProcess: aLogicalProcess [
	"Direction Network -> ASP"

	self
		performMTPTransferRequestPrimitiveFor: aPayloadData
		toLogicalProcess: aLogicalProcess
]
