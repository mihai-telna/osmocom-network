"
I hold the M3UA specific constants
"
Class {
	#name : #M3UAConstants,
	#superclass : #Object,
	#category : #'M3UA-Core'
}

{ #category : #constants }
M3UAConstants class >> applicationM3UA [
	"Developer 's choice"

	^ 1
]

{ #category : #constants }
M3UAConstants class >> clsASPSM [
	^ 3
]

{ #category : #constants }
M3UAConstants class >> clsASPTM [
	^ 4
]

{ #category : #constants }
M3UAConstants class >> clsMGMT [
	^ 0
]

{ #category : #constants }
M3UAConstants class >> clsRKM [
	^ 9
]

{ #category : #constants }
M3UAConstants class >> clsSSNM [
	^ 2
]

{ #category : #constants }
M3UAConstants class >> clsTransfer [
	^ 1
]

{ #category : #constants }
M3UAConstants class >> spare [
	^ 0
]

{ #category : #tags }
M3UAConstants class >> tagASPIdentifier [
	^ 17
]

{ #category : #tags }
M3UAConstants class >> tagAffectedPointCode [
	^ 18
]

{ #category : #tags }
M3UAConstants class >> tagConcernedDestination [
	^ 518
]

{ #category : #tags }
M3UAConstants class >> tagCongestionIndications [
	^ 517
]

{ #category : #tags }
M3UAConstants class >> tagCorrelationID [
	^ 19
]

{ #category : #tags }
M3UAConstants class >> tagDeregistrationResult [
	^ 521
]

{ #category : #tags }
M3UAConstants class >> tagDeregistrationStatus [
	^ 531
]

{ #category : #tags }
M3UAConstants class >> tagDestinationPointCode [
	^ 523
]

{ #category : #tags }
M3UAConstants class >> tagDiagnosticInformation [
	^ 7
]

{ #category : #tags }
M3UAConstants class >> tagHeartbeatData [
	^ 9
]

{ #category : #tags }
M3UAConstants class >> tagINFOString [
	^ 4
]

{ #category : #tags }
M3UAConstants class >> tagLocalRoutingKeyIdentifier [
	^ 522
]

{ #category : #tags }
M3UAConstants class >> tagMGMTErrorCode [
	^ 12
]

{ #category : #tags }
M3UAConstants class >> tagMGMTNotifyInfoString [
	^ 4
]

{ #category : #tags }
M3UAConstants class >> tagMGMTNotifyRoutingContext [
	^ 6
]

{ #category : #tags }
M3UAConstants class >> tagMGMTNotifyStatus [
	^ 13
]

{ #category : #tags }
M3UAConstants class >> tagNetworkAppearance [
	^ 512
]

{ #category : #tags }
M3UAConstants class >> tagOriginatingPointCodeList [
	^ 526
]

{ #category : #tags }
M3UAConstants class >> tagProtocolData [
	^ 528
]

{ #category : #tags }
M3UAConstants class >> tagRegistrationResult [
	^ 520
]

{ #category : #tags }
M3UAConstants class >> tagRegistrationStatus [
	^ 530
]

{ #category : #tags }
M3UAConstants class >> tagReserved [
	^ 0
]

{ #category : #tags }
M3UAConstants class >> tagRoutingContext [
	^ 6
]

{ #category : #tags }
M3UAConstants class >> tagRoutingKey [
	^ 519
]

{ #category : #tags }
M3UAConstants class >> tagServiceIndicators [
	^ 524
]

{ #category : #tags }
M3UAConstants class >> tagTrafficModeType [
	^ 11
]

{ #category : #tags }
M3UAConstants class >> tagUserCause [
	^ 516
]

{ #category : #constants }
M3UAConstants class >> typeAspSmASPDN [
	"ASP State Maintenance (ASPSM) Messages
      2 ASP Down (ASPDN)"

	^ 2
]

{ #category : #constants }
M3UAConstants class >> typeAspSmASPDNACK [
	"ASP State Maintenance (ASPSM) Messages
      5 ASP Down Acknowledgement (ASPDN ACK)"

	^ 5
]

{ #category : #constants }
M3UAConstants class >> typeAspSmASPUP [
	"ASP State Maintenance (ASPSM) Messages
      1 ASP Up (ASPUP)"

	^ 1
]

{ #category : #constants }
M3UAConstants class >> typeAspSmASPUPACK [
	"ASP State Maintenance (ASPSM) Messages
      4 ASP Up Acknowledgement (ASPUP ACK)"

	^ 4
]

{ #category : #constants }
M3UAConstants class >> typeAspSmBEAT [
	"ASP State Maintenance (ASPSM) Messages
      3 Heartbeat (BEAT)"

	^ 3
]

{ #category : #constants }
M3UAConstants class >> typeAspSmBEATACK [
	"ASP State Maintenance (ASPSM) Messages
      6 Heartbeat Acknowledgement (BEAT ACK)"

	^ 6
]

{ #category : #constants }
M3UAConstants class >> typeAspTmASPAC [
	"ASP Traffic Maintenance (ASPTM) Messages
      1 ASP Active (ASPAC)"

	^ 1
]

{ #category : #constants }
M3UAConstants class >> typeAspTmASPACACK [
	"ASP Traffic Maintenance (ASPTM) Messages
      3 ASP Active Acknowledgement (ASPAC ACK)"

	^ 3
]

{ #category : #constants }
M3UAConstants class >> typeAspTmASPIA [
	"ASP Traffic Maintenance (ASPTM) Messages
      2 ASP Inactive (ASPIA)"

	^ 2
]

{ #category : #constants }
M3UAConstants class >> typeAspTmASPIAACK [
	"ASP Traffic Maintenance (ASPTM) Messages
      4 ASP Unactive Acknowledgement (ASPIA ACK)"

	^ 4
]

{ #category : #constants }
M3UAConstants class >> typeMgmtERR [
	"Management (MGMT) Messages
      0 Error (ERR)"

	^ 0
]

{ #category : #constants }
M3UAConstants class >> typeMgmtNTFY [
	"Management (MGMT) Messages
      1 Notify (NTFY)"

	^ 1
]

{ #category : #constants }
M3UAConstants class >> typeRkmDEREGREQ [
	"Routing Key Management (RKM) Messages
      3 Deregistration Request (DEREG REQ)"

	^ 3
]

{ #category : #constants }
M3UAConstants class >> typeRkmDEREGRSP [
	"Routing Key Management (RKM) Messages
      4 Deregistration Response (DEREG RSP)"

	^ 4
]

{ #category : #constants }
M3UAConstants class >> typeRkmREGREQ [
	"Routing Key Management (RKM) Messages
      1 Registration Request (REG REQ)"

	^ 1
]

{ #category : #constants }
M3UAConstants class >> typeRkmREGRSP [
	"Routing Key Management (RKM) Messages
      2 Registration Response (REG RSP)"

	^ 2
]

{ #category : #constants }
M3UAConstants class >> typeSsnmDAUD [
	"SS7 Signalling Network Management (SSNM) Messages
     3 Destination State Audit (DAUD)"

	^ 3
]

{ #category : #constants }
M3UAConstants class >> typeSsnmDAVA [
	"SS7 Signalling Network Management (SSNM) Messages
      2 Destination Available (DAVA)"

	^ 2
]

{ #category : #constants }
M3UAConstants class >> typeSsnmDRST [
	"SS7 Signalling Network Management (SSNM) Messages
     6 Destination Restricted (DRST)"

	^ 6
]

{ #category : #constants }
M3UAConstants class >> typeSsnmDUNA [
	"SS7 Signalling Network Management (SSNM) Messages
      1 Destination Unavailable (DUNA)"

	^ 1
]

{ #category : #constants }
M3UAConstants class >> typeSsnmDUPU [
	"SS7 Signalling Network Management (SSNM) Messages
     5 Destination User Part Unavailable (DUPU)"

	^ 5
]

{ #category : #constants }
M3UAConstants class >> typeSsnmSCON [
	"SS7 Signalling Network Management (SSNM) Messages
     4 Signalling Congestion (SCON)"

	^ 4
]

{ #category : #constants }
M3UAConstants class >> typeTransferDATA [
	"Transfer Messages
      1 Payload Data (DATA)"

	^ 1
]

{ #category : #constants }
M3UAConstants class >> version [
	^ 1
]
