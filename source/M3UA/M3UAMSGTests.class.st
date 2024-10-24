Class {
	#name : #M3UAMSGTests,
	#superclass : #TestCase,
	#category : #'M3UA-Tests'
}

{ #category : #'m3ua messages' }
M3UAMSGTests class >> m3uaAspAcAck [
	^ByteArray readHexFrom: '0100040300000018000b0008000000020006000800000038'
]

{ #category : #'m3ua messages' }
M3UAMSGTests class >> m3uaAspUp [
	^ByteArray readHexFrom: '0100030100000008'
]

{ #category : #'m3ua messages' }
M3UAMSGTests class >> m3uaAspUpAck [
	^ByteArray readHexFrom: '0100030400000008'
]

{ #category : #'m3ua messages' }
M3UAMSGTests class >> m3uaAspac [
	^ByteArray readHexFrom: '0100040100000018000b0008000000020006000800000038'
]

{ #category : #'m3ua messages' }
M3UAMSGTests class >> m3uaNotify [
	^ByteArray readHexFrom: '0100000100000018000d0008000100030006000800000038'
]

{ #category : #'m3ua messages' }
M3UAMSGTests class >> m3uaPayloadDataFrame [
	"Frame 1: 172 bytes on wire (1376 bits), 188 bytes captured (1504 bits) on interface -, id 0
Linux cooked capture v1
Internet Protocol Version 4, Src: 10.26.30.172, Dst: 199.255.7.133
Stream Control Transmission Protocol, Src Port: 2918 (2918), Dst Port: 2814 (2814)
MTP 3 User Adaptation Layer
    Version: Release 1 (1)
    Reserved: 0x00
    Message class: Transfer messages (1)
    Message Type: Payload data (DATA) (1)
    Message length: 92
    Protocol data (SS7 message of 57 bytes)
        Parameter Tag: Protocol data (528)
        Parameter length: 73
        OPC: 61
        DPC: 20
        SI: SCCP (3)
        NI: Reserved for national use (3)
        MP: 0
        SLS: 9
        [MTP3 equivalents]
        Padding: 000000
    Routing context (1 context)
        Parameter Tag: Routing context (6)
        Parameter length: 8
        Routing context: 61
Signalling Connection Control Part
Transaction Capabilities Application Part
GSM Mobile Application
"
	^ByteArray readHexFrom: '010001010000005c021000490000003d00000014030300090980030f1c0c1206001204080501000001200d129500110408245637011345031865164804d39aa6d3490400a4404c6c08a106020103020138000000000600080000003d'
]

{ #category : #tests }
M3UAMSGTests >> testParseDifferentTags [
	
	| tag |
	"M3UATagAffectedPointCode"
	tag := M3UATagAffectedPointCode
				initDataWithNInteger24bits: (OrderedCollection with: 66 with: 77 with: 88)
				paddingFirstWith: (OrderedCollection with: 0 with: 4 with: 2).
	self assert: tag affectedPointCodes equals: (OrderedCollection with: 66 with: 77 with: 88).
	
	"M3UATagConcernedDestination"
	tag := M3UATagConcernedDestination
				initDataWithInteger24bits: 55
				paddingFirstWith: 0.
	self assert: tag concernedDestination equals: 55.

	"M3UATagCongestionIndications"
	tag := M3UATagCongestionIndications
				initDataWithOneInteger32bits: 2.
	self assert: tag congestionLevelField equals: 2.
	tag := M3UATagCongestionIndications
				initDataWithOneInteger32bits: 3.
	self assert: tag isCongestionLevel3.

	"M3UATagDeregistrationStatus"
	tag := M3UATagDeregistrationStatus
				initDataWithOneInteger32bits: 5.
	self assert: tag isASPCurrentlyActiveForRoutingContext.
	
	"M3UATagDestinationPointCode"
	tag := M3UATagDestinationPointCode
						initDataWithInteger24bits: 44
						paddingFirstWith: 1.
	self assert: tag destinationPointCode equals: 44.

	"M3UATagMGMTErrorCode"
	tag := M3UATagMGMTErrorCode initWithData: 7 asByteArray.
	self assert: tag isProtocolError.

	"M3UATagMGMTNotifyStatus"
	tag := M3UATagMGMTNotifyStatus
		type: 1
		info: 3.
	self assert: tag statusInfo equals: 3.
	self assert: tag statusType equals: 1.
	self assert: tag isInfoAsActive.
	self assert: tag isTypeApplicationServerStateChange.
	
	"M3UATagOriginatingPointCodeList"
	tag := M3UATagOriginatingPointCodeList
				initDataWithNInteger24bits: (OrderedCollection with: 66 with: 77 with: 88)
				paddingFirstWith: (OrderedCollection with: 0 with: 4 with: 2).
	self assert: tag originatingPointCodes equals: (OrderedCollection with: 66 with: 77 with: 88).
	
	"M3UATagRegistrationStatus"
	tag := M3UATagRegistrationStatus
				initDataWithOneInteger32bits: 3.
	self assert: tag isErrorInvalidNetworkAppearance.

	"M3UATagTrafficModeType"
	tag := M3UATagTrafficModeType
				initDataWithOneInteger32bits: 2.
	self assert: tag isLoadshare.

	"M3UATagUserCause"
	tag := M3UATagUserCause
				initDataWithTwoInteger16bits: (OrderedCollection with: 1 with: 4).
	self assert: tag unavailabilityCauseField equals: 1.
	self assert: tag mtp3UserIdentityField equals: 4.
	self assert: tag isUnavailabilityUnequippedRemoteUser.
	self assert: tag isMtp3UserIdentityTUP.
	
]

{ #category : #tests }
M3UAMSGTests >> testParseMessage [
	| inp msg tagStatus tagRoutingContext tagTrafficMode protocolDataTag sccpMsg |
	inp := self class m3uaNotify.
	msg := M3UAMSG parseToClassFromStream: inp.
	self assert: msg class equals: M3UANotifyMessage.
	self assert: msg msgClass equals: M3UANotifyMessage messageClass.
	self assert: msg msgType equals: M3UAConstants typeMgmtNTFY.
	self assert: (tagStatus := msg findTag: M3UAConstants tagMGMTNotifyStatus) notNil.
	self assert: tagStatus isTypeApplicationServerStateChange.
	self assert: tagStatus isInfoAsActive.	
	self assert: (tagRoutingContext := msg findTag: M3UAConstants tagMGMTNotifyRoutingContext) notNil.
	self assert: tagRoutingContext data asInteger equals: 56.	

	inp := self class m3uaAspac.
	msg := M3UAMSG parseToClassFromStream: inp.
	self assert: msg class equals: M3UAASPActiveMessage.
	self assert: msg msgClass equals: M3UAASPActiveMessage messageClass.
	self assert: msg msgType equals: M3UAConstants typeAspTmASPAC.
	self assert: (tagTrafficMode := msg findTag: M3UAConstants tagTrafficModeType) notNil.
	self assert: tagTrafficMode isLoadshare.
	self assert: (tagRoutingContext := msg findTag: M3UAConstants tagMGMTNotifyRoutingContext) notNil.
	self assert: tagRoutingContext data asInteger equals: 56.	

	inp := self class m3uaAspAcAck.
	msg := M3UAMSG parseToClassFromStream: inp.
	self assert: msg class equals: M3UAASPActiveAckMessage.
	self assert: msg msgClass equals: M3UAASPActiveAckMessage messageClass.
	self assert: msg msgType equals: M3UAConstants typeAspTmASPACACK.
	self assert: (tagTrafficMode := msg findTag: M3UAConstants tagTrafficModeType) notNil.
	self assert: tagTrafficMode isLoadshare.
	self assert: (tagRoutingContext := msg findTag: M3UAConstants tagMGMTNotifyRoutingContext) notNil.
	self assert: tagRoutingContext data asInteger equals: 56.	
 
	inp := self class m3uaAspUp.
	msg := M3UAMSG parseToClassFromStream: inp.
	self assert: msg class equals: M3UAASPUpMessage.
	self assert: msg msgClass equals: M3UAASPUpMessage messageClass.
	self assert: msg msgType equals: M3UAConstants typeAspSmASPUP.
	self assert: msg tags isEmpty.
	
	inp := self class m3uaAspUpAck.
	msg := M3UAMSG parseToClassFromStream: inp.
	self assert: msg class equals: M3UAASPUpAckMessage.
	self assert: msg msgClass equals: M3UAASPUpAckMessage messageClass.
	self assert: msg msgType equals: M3UAConstants typeAspSmASPUPACK.
	self assert: msg tags isEmpty.
	
	inp := self class m3uaPayloadDataFrame.
	msg := M3UAMSG parseToClassFromStream: inp.
	self assert: msg class equals: M3UAPayloadDataMessage.
	self assert: (protocolDataTag := msg tags first) class equals: M3UATagProtocolData.
	self assert: msg tags last class equals: M3UATagRoutingContext.
	self assert: protocolDataTag opcField equals: 61.
	self assert: protocolDataTag dpcField equals: 20.
	self assert: protocolDataTag siField equals: 3.
	self assert: protocolDataTag niField equals: 3.
	self assert: protocolDataTag mpField equals: 0.
	self assert: protocolDataTag slsField equals: 9.
	sccpMsg := SCCPMessage decode: protocolDataTag userProtocolData.
	self assert: sccpMsg class equals: SCCPUDT.
	self assert: sccpMsg calledAddr parseGlobalTitle addr
		equals: '80501000001002'.
	self assert: sccpMsg callingAddr parseGlobalTitle addr
		equals: '804265731031543'.
  


	
]

{ #category : #tests }
M3UAMSGTests >> testParseMessageRecursiveTag [
	|  routingKeyTag buffer byteArray readTag tagLocalRoutingKeyIdentifier tagRoutingContext tagTrafficModeType tagNetworkAppearance tagServiceIndicators tagOriginatingPointCodeList tagDestinationPointCode routingKeys msg readMsg tags |
	routingKeys := M3UAApplicationServerProcessTest
		routingKeysWithTrafficModeType: M3UAASConfiguration defaultTrafficModeType.
	routingKeyTag := M3UATagRoutingKey fromRoutingKey: routingKeys first.
	
	"writing"
	buffer := MessageBuffer new.
	routingKeyTag writeOn: buffer.
	byteArray := buffer asByteArray.
	
	"reading"
	readTag := M3UATag parseToClassFromStream: byteArray readStream.
	self assert: readTag class equals: M3UATagRoutingKey.
	tagLocalRoutingKeyIdentifier := readTag findTag: M3UAConstants tagLocalRoutingKeyIdentifier.
	self assert: tagLocalRoutingKeyIdentifier notNil.
	self assert: tagLocalRoutingKeyIdentifier data asInteger equals: 1.
	tagRoutingContext := readTag findTag: M3UAConstants tagRoutingContext.
	self assert: tagRoutingContext notNil.
	self assert: tagRoutingContext data asInteger equals: 12345.
	tagTrafficModeType := readTag findTag: M3UAConstants tagTrafficModeType.
	self assert: tagTrafficModeType notNil.
	self assert: tagTrafficModeType data asInteger equals: M3UAASConfiguration defaultTrafficModeType.
	tagNetworkAppearance := readTag findTag: M3UAConstants tagNetworkAppearance.
	self assert: tagNetworkAppearance notNil.
	self assert: tagNetworkAppearance data asInteger equals: 777.
	tagServiceIndicators :=readTag findTag: M3UAConstants tagServiceIndicators.
	self assert: tagServiceIndicators notNil.
	self assert: (tagServiceIndicators data asArray includes: 12).
	self assert: (tagServiceIndicators data asArray includes: 34).
	tagOriginatingPointCodeList := readTag findTag: M3UAConstants tagOriginatingPointCodeList.
	self assert: tagOriginatingPointCodeList notNil.
	self assert:  (tagOriginatingPointCodeList data copyFrom: 1 to: 4) asInteger equals: 33333.
	self assert:  (tagOriginatingPointCodeList data copyFrom: 5 to: 8) asInteger equals: 44444.
	tagDestinationPointCode := readTag findTag: M3UAConstants tagDestinationPointCode.
	self assert: tagDestinationPointCode notNil.
	self assert: tagDestinationPointCode data asInteger equals: 11111.
	
	"message"
	msg := M3UARegistrationRequestMessage newMessage.
	routingKeys
		do:
			[ :aRoutingKey | msg addTag: (M3UATagRoutingKey fromRoutingKey: aRoutingKey) ].
		
	"writing"
	buffer := MessageBuffer new.
	msg writeOn: buffer.
	byteArray := buffer asByteArray.
	
	"reading"
	readMsg := M3UAMSG parseToClassFromStream: byteArray readStream.
	self assert: readMsg class equals: M3UARegistrationRequestMessage.
	tags := readMsg findAllTags: M3UAConstants tagRoutingKey.
	self assert: tags size equals: 2
	
]

{ #category : #tests }
M3UAMSGTests >> testParseTagAffectedPointCode [
	| tag |
	tag := M3UATagAffectedPointCode
		initDataWithNInteger24bits: #(5 7 6 9)
		paddingFirstWith: #(0 0 0 0).
	self assert: tag affectedPointCodes equals: #(5 7 6 9) asOrderedCollection
]
