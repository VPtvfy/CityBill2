package S12WR1A;
use base 'Source';

use Convert::ASN1;
use Data::Dumper;
use strict;

sub readFile {
  my $self = shift();
  my $process = shift();

  my $asn = Convert::ASN1->new;
  $asn->prepare(ASN::desc()) or Logger::die $asn->error;
  my $test = $asn->find('CDR-File');

  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
		$atime,$mtime,$ctime,$blksize,$blocks) = stat $$self{filehandle};

  my $buffer;

  read $$self{filehandle}, $buffer, $size;

  my $out = $test->decode($buffer) or Logger::die $test->error;
  
  for my $x (@{$out->{body}}) {
    for my $y (@{$x->{additionalRecordTypes}}) {
      for my $z (keys %$y) {
        for my $recType (keys %{$y->{$z}}) {
	      my $ref = $y->{$z}{$recType};
	      my $recTypeName = $recType;
	      $recType =~ s/\-//g;
#          next unless $recType eq 'dBSubscriberRecordType';
	      my $rec = $recType->new($ref,$recTypeName);
          $process->($rec);
          $self->{fileblocks}++}}}}}

sub ftime {
  my $self = shift;
  my $ftime = $self->filebasename;
  return $self->filetime if (!($ftime =~ /^(ats|ATS)\d+\.(\d\d\d\d)\.(\d\d).(\d\d)/));
  join("-",$2,$3,$4) . " 00:00:00"}

sub tablename {
  "S12WR1A"}

sub fields{
  qw/trunk_in trunk_out caller peer calltime duration/}

1;
#############################################################
package S12WR1ARecord;
use base 'CDR';
use Data::Dumper;

sub asString {
  my $self = shift;
  my $res="";
#  my $res = "%4s %-10.10s %-10.10s %15s %15s %15s %10s %5u", 
#	$self->calltype, 
#	$self->trunk_in,
#	$self->trunk_out,
#	$self->caller, 
#	$self->peer, 
#	$self->calltime, 
#	$self->duration;
  foreach (qw/trunk_in trunk_out caller peer calltime duration/) {
    $res .= sprintf(" %s - '%s'",$_,$self->$_) if $_}
  $res}


sub new {
  my ($class, $record, $rt) = @_;
  my $self = {};
  my %tmp;

  for my $item (@{$record->{participantInfo}}, $record->{additionalParticipantInfo}, 
       $record->{callDuration}, $record->{startTimeStamp}) {
    for my $key (keys %$item) {
      $tmp{$key} = $item->{$key}}};


  $$self{caller} = number($tmp{callingPartyNumber});

  $$self{peer}   = number($tmp{calledPartyNumber});
  $$self{peer} =~ s/^3232(\d{6})$/$1/;
  $$self{peer} =~ s/^7232(\d{6})$/$1/;
  
  $$self{calltime} = date($tmp{answerTime} || $tmp{seizureTime} || $tmp{partialTime} || $tmp{eventTime});
  $$self{duration} = _duration($tmp{conversationTime});
  
  $$self{trunk_out} = $record->{trunkGroupOutgoing}{trunkGroupId}{pString} if exists $record->{trunkGroupOutgoing}{trunkGroupId}{pString};
  $$self{trunk_in} = $record->{trunkGroupIncoming}{trunkGroupId}{pString} if exists $record->{trunkGroupIncoming}{trunkGroupId}{pString};
  
  bless $self, $class}

sub number {
    my ($x, $y, $num) = unpack "B8B8H100", shift();
    # при нечетном числе символов последний символ удаляется
    if (substr($x, 0, 1)) {substr ($num, -1, 1) = ''};
    $num}

sub digits {
  my ($h, $num) =  unpack "B8H100", shift();
  return $num}

sub date {
 my ($YY, $MM, $DD, $HH, $mm, $SS, $CC) = unpack("H2H2H2H2H2H2H2", shift());
 sprintf("%04d-%02d-%02d %02d:%02d:%02d", 2000 + $YY,  $MM, $DD, $HH, $mm, $SS)}

sub _duration {
  use POSIX;
  my $result;
  for my $x (unpack "C3", shift()) {
    $result = ($result << 8) | $x};
  return POSIX::ceil($result/100)}

##############################################################
package dBSubscriberRecordType;
use base 'S12WR1ARecord';

##############################################################
package dBSSRecordType;
use base 'S12WR1ARecord';

##############################################################
package dBTrunkRecordType;
use base 'S12WR1ARecord';

##############################################################
package dBBCGRecordType;
use base 'S12WR1ARecord';

##############################################################
package dBINRecordType;
use base 'S12WR1ARecord';

##############################################################
package ASN;

sub desc {
<<'END';
CDR-File ::= SEQUENCE {
  header	[0]	FileHeaderRecord		OPTIONAL,
  body		[1]	SEQUENCE OF RecordContent}


FileHeaderRecord ::= SEQUENCE {
  productionDateTime	StartDateTime,
  exchangeInfo		ExchangeInfo,
  fileName		FileName,
  reasonForOutput	ReasonForOutput,
  firstRecordId		RecordId	OPTIONAL}


RecordContent ::= CHOICE {
  additionalRecordTypes	[3] ManagementExtensions}


CallRecord ::= SET {
  recordType				[0]	RecordType,
  startTimeStamp			[1]	StartTimeStamp,
  participantInfo			[2]	ParticipantInfo,
  bearerService				[3]	BearerService,
  serviceUser				[4]	ServiceUser,
  callIdentificationNumber		[6]	CallIdentificationNumber,
  supplementaryServices			[5]	SupplementaryServices		OPTIONAL,
  immediateNotificationForUsageMetering	[7]	ImmediateNotification		OPTIONAL,
  cause					[8]	Cause				OPTIONAL,
  iNSpecificInfo			[9]	INSpecificInfo			OPTIONAL,
  partialGeneration			[10]	PartialGeneration		OPTIONAL,
  exchangeInfo				[11]	ExchangeInfo			OPTIONAL,
  relatedCallNumber			[12]	RelatedCallNumber		OPTIONAL,
  cDRPurpose				[13]	CDRPurpose			OPTIONAL,
  additionalParticipantInfo		[14]	AdditionalParticipantInfo	OPTIONAL,
  callingPartyCategory			[15]	CallingPartyCategory		OPTIONAL,
  callingPartyType			[16]	CallingPartyType		OPTIONAL,
  chargingInformation			[17]	ChargingInformation		OPTIONAL,
  progress				[18]	Progress			OPTIONAL,
  accessDelivery			[19]	AccessDelivery			OPTIONAL,
  trunkGroupOutgoing			[20]	TrunkGroupOutgoing		OPTIONAL,
  trunkGroupIncoming			[21]	TrunkGroupIncoming		OPTIONAL,
  fallbackBearerService			[22]	FallbackBearerService		OPTIONAL,
  teleservice				[23]	Teleservice			OPTIONAL,
  callDuration				[24]	CallDuration			OPTIONAL,
  uUInfo				[25]	UUInfo				OPTIONAL,
  standardExtensions			[26]	StandardExtensions		OPTIONAL,
  recordExtensions			[30]	RecordExtensions		OPTIONAL,
  b-PartyCategory			[31]	B-PartyCategory			OPTIONAL,
  iSUPPreferred				[32]	ISUPPreferred			OPTIONAL,
  networkManagementControls		[33]	NetworkManagementControls	OPTIONAL,
  glare					[34]	Glare				OPTIONAL,
  recordId				[35]	RecordId			OPTIONAL,
  dataValidity				[36]	DataValidity			OPTIONAL,
  callStatus				[37]	CallStatus			OPTIONAL,
  carrierId				[38]	CarrierId			OPTIONAL,
  dPC					[39]	PointCode			OPTIONAL,
  oPC					[40]	PointCode			OPTIONAL
}

RecordType ::= INTEGER 


StartTimeStamp ::= CHOICE {
	answerTime		[0]		StartDateTime,
	seizureTime		[1]		StartDateTime,
	partialTime		[2]		StartDateTime,
	eventTime		[3]		StartDateTime
}

ParticipantInfo	::= SET OF ParticipantId

ParticipantId ::= CHOICE {
	callingPartyNumber		[0]	CallingPartyNumber,
	calledPartyNumber		[1]	CalledPartyNumber,
	redirectingNumber		[2]	RedirectingNumber,
	redirectionNumber		[3]	RedirectionNumber,
	originalCalledNumber		[4]	OriginalCalledNumber,
	callingPartyNumberNotScreened	[5]	CallingPartyNumberNotScreened,
	operatorSpecific1Number		[6]	OperatorSpecific1Number,
	operatorSpecific2Number		[7]	OperatorSpecific2Number,
	operatorSpecific3Number		[8]	OperatorSpecific3Number
}

CallingPartyNumber			::=	Number
CalledPartyNumber			::=	Number
RedirectingNumber			::=	Number
RedirectionNumber			::=	Number
OriginalCalledNumber			::=	Number
CallingPartyNumberNotScreened		::=	Number
OperatorSpecific1Number			::=	Number
OperatorSpecific2Number			::=	Number
OperatorSpecific3Number			::=	Number
OperatorSpecific1AdditionalNumber	::=	Number
OperatorSpecific2AdditionalNumber	::=	Number
OperatorSpecific3AdditionalNumber	::=	Number


ServiceUser				::=	ParticipantType

SupplementaryServices			::=	SEQUENCE OF SupplementaryService

SupplementaryService ::= SEQUENCE {
  supplementaryServiceCode	SupplementaryServiceCode,
  supplementaryAction		SupplementaryAction,
  supplementarytimestamp	Duration			OPTIONAL,
  functionalInformation		ManagementExtensions		OPTIONAL}


SupplementaryServiceCode	::=	OCTET STRING 

SupplementaryAction		::=	ENUMERATED {
  provision (0),
  withdrawal (1),
  registration (2),
  erasure (3),
  activation (4),
  deactivation (5),
  invocation (6),
  disabling (7),
  interrogation (8),
  verification (100)
}


ImmediateNotification		::=	BOOLEAN

Cause				::=	SEQUENCE {
  causeValue		CauseValue,
  location		Location
}

CauseValue				::=	BIT STRING 

INSpecificInfo				::=	SET {
	personalUserId			[0]	PersonalUserId			OPTIONAL,
	chargedParticipant		[1]	ChargedParticipant		OPTIONAL,
	chargedDirectoryNumber		[2]	ChargedDirectoryNumber		OPTIONAL,
	percentageToBeBilled		[3]	PercentageToBeBilled		OPTIONAL,
	accountCodeInput		[4]	AccountCodeInput		OPTIONAL,
	iNServiceCode			[5]	INServiceCode			OPTIONAL,
	queueInfo			[6]	QueueInfo			OPTIONAL,
	serviceSpecificINInformation	[7]	ServiceSpecificINInformation	OPTIONAL
}


ChargedParticipant		::=	ParticipantType

ChargedDirectoryNumber		::=	Number

PercentageToBeBilled		::=	INTEGER 

AccountCodeInput		::=	OCTET STRING 

INServiceCode			::=	OCTET STRING 

QueueInfo ::= SEQUENCE {
  queueTimeStamp	[0]	StartDateTime,
  queueDuration		[1]	Duration
}

PartialGeneration ::= SET {
  partialRecordNumber	[0]	PartialRecordNumber,
  partialRecordReason	[1]	PartialRecordReason
}

PartialRecordNumber		::=	BIT STRING 

PartialRecordReason		::=	ENUMERATED {
  timeLimit			(0),			-- This is used for long duration calls.
  serviceChange			(1),
  overflow			(2),
  networkInternalReasons 		(3),
  lastCDR				(4),
  timeChange			(5)
}


RelatedCallNumber		::=	CallIdentificationNumber

AdditionalParticipantInfo	::=	SET {
  physicalLineCode			[0]	PhysicalLineCode			OPTIONAL,
  receivedDigits			[1]	ReceivedDigits				OPTIONAL,
  operatorSpecific1AdditionalNumber	[2]	OperatorSpecific1AdditionalNumber	OPTIONAL,
  operatorSpecific2AdditionalNumber	[3]	OperatorSpecific2AdditionalNumber	OPTIONAL,
  operatorSpecific3AdditionalNumber	[4]	OperatorSpecific3AdditionalNumber	OPTIONAL
}

PhysicalLineCode		::=	VisibleString
ReceivedDigits			::=	OCTET STRING 
CallingPartyCategory		::=	BIT STRING 

CallingPartyType ::= ENUMERATED {
  analogue (0),
  customerLink (1),		
  basicAccess (2),
  primaryRateAccess (3)
}


Progress ::=	SEQUENCE {
  description	ProgressDescription,
  location	Location
}

ProgressDescription		::=	INTEGER 
AccessDelivery			::=	BIT STRING 
TrunkGroupOutgoing		::=	TrunkGroupId
TrunkGroupIncoming		::=	TrunkGroupId
FallbackBearerService		::=	BearerService
Teleservice			::=	BIT STRING 

CallDuration ::= SET {
  conversationTime	[0]	ConversationTime	OPTIONAL,
  durationTimeACM	[1]	DurationTimeACM		OPTIONAL,
  durationTimeB-ans	[2]	DurationTimeANM		OPTIONAL,
  durationTimeNoANM	[3]	DurationTimeNoANM	OPTIONAL
}

ConversationTime	::=	Duration
DurationTimeACM		::=	Duration
DurationTimeANM		::=	Duration  --fix to match reference syntax
DurationTimeNoANM	::=	Duration  --fix to match reference syntax


UUInfo ::= SET {
  uu1Info	[0]	UUxInfo		OPTIONAL,
  uu2Info	[1]	UUxInfo		OPTIONAL,
  uu3Info	[2]	UUxInfo		OPTIONAL
}

UUxInfo	::= SET {
  receivedMessages		[0]	Count	OPTIONAL,
  transmittedMessages		[1]	Count	OPTIONAL,
  receivedOctets		[2]	Count	OPTIONAL,
  transmittedOctets		[3]	Count	OPTIONAL
}


StandardExtensions		::=	ManagementExtensions
RecordExtensions		::=	ManagementExtensions
B-PartyCategory			::=	BIT STRING 


ISUPPreferred ::= ENUMERATED {
  preferred (0),
  notrequired (1),
  required (2),
  notapplicable (3)
}



NetworkManagementControls	::=	ENUMERATED {
  acc				(0),
  adc				(1),
  cancelFrom			(2),
  cancelRerouted		(3),
  cancelTo			(4),
  destinationCodeControl	(5),
  scr				(6),
  skip				(7),
  tarfrom			(8),
  tarto				(9)
}

Glare					::=	BOOLEAN

DataValidity ::= ENUMERATED {
  possibleduplicated	(0),
  requireddatamissing	(1),
  other			(2)
}

CallStatus ::= ENUMERATED {
  answered	(0),
  notanswered	(1)
}


CarrierId	::=	VisibleString 
StartDateTime	::=	OCTET STRING 


ExchangeInfo ::= SET {
  exchangeID		[0]	ExchangeID		OPTIONAL,
  softwareVersion	[1]	SoftwareVersion	OPTIONAL
}


ExchangeID		::=	VisibleString 
SoftwareVersion		::=	VisibleString  

NameType ::= CHOICE {
 numericName	INTEGER,
 pString		GraphicString	-- UNIVERSAL 25
}


ReasonForOutput	::= ENUMERATED {
  absoluteTimeEvent		(0),
  maxBlockSizeReached		(1),
  maxTimeIntervalElapsed	(2),
  internalSizeLimitReached	(3),
  oSAction			(4)
}


RecordId		::=	Count
ManagementExtensions	::=	SET OF ManagementExtension
Count			::=	OCTET STRING 
Number			::=	OCTET STRING 


TMPCap ::= ENUMERATED {
  speech			(0),
  audio3dot1kHZ		(1),
  uni64			(2),
  uni64withT-A		(3),
  multipleRate		(4),
  packetModeB-Ch	(5),
  packetModeBd-Ch	(100),
  other			(101)
}

BearerService ::= SEQUENCE {
  capability TMPCap,
  multiplier INTEGER OPTIONAL
}


ParticipantType ::= ENUMERATED {
 callingPartyNumber		(0),
 calledPartyNumber		(1),
 redirectingNumber		(2),
 redirectionNumber		(3),
 originalCalledNumber		(4),
 callingPartyNumberNotScreened	(5),
 operatorSpecific1Number	(6),
 operatorSpecific2Number	(7),
 operatorSpecific3Number	(8),
 operator			(9),
 unknown			(10),
 unknownCPI			(100),
 notApplicableCPI		(101),
 callingPartyCharged		(102),
 calledPartyCharged		(103),
 connectedPartyCharged		(104),
 noPartyCharged			(105),
 referToINSpecificInfo		(106)
}

CallIdentificationNumber	::=	OCTET STRING
Duration			::=	OCTET STRING 
Location			::=	INTEGER 

ChargingInformation ::= CHOICE {
  recordedCurrency		[0]	RecordedCurrency,
  recordedUnitsList		[1]	RecordedUnitsList,
  freeOfCharge			[2]	NULL,
  chargeInfoNotAvailable	[3]	NULL
}


RecordedCurrency			::=	CHOICE {
  currency			[0]	IA5String,
  amount			[1]	Amount
}

Amount	::=	SEQUENCE {
  currencyAmount	[0]	NumberOfUnits,
  multiplier		[1]	Multiplier
}

Multiplier ::= ENUMERATED {
  oneThousandth	(0),
  oneHundredth	(1),
  oneTenth	(2),
  one		(3),
  ten		(4),
  hundred	(5),
  thousand	(6)
}

RecordedUnitsList ::= SEQUENCE OF RecordedUnits

TMPUnits ::= CHOICE {
 recordedNumberOfUnits	[0]	NumberOfUnits,
 notAvailable		[1]	NULL
}

RecordedUnits	::=	SEQUENCE {
	units TMPUnits,
	recordedTypeOfUnits			INTEGER OPTIONAL
}

NumberOfUnits			::=	INTEGER 

TrunkGroupId			::=	SEQUENCE {
	trunkGroupId		[0]	NameType,
	trunkId			[1]	NameType	OPTIONAL,
	pCMId			[2]	NameType	OPTIONAL,
	channelNumber		[3]	INTEGER		OPTIONAL
}


PointCode	::=	INTEGER


ManagementExtension		::=	CHOICE {
-- at file/block/recordContent level:
	fileHeaderRecord-ME				[0]	NULL,					-- NOT USED for RUCIS
	blockHeaderRecord-ME				[1]	NULL,					-- NOT USED for RUCIS
	standardAdditionalRecordTypes-ME	[2]	NULL,					-- NOT USED for RUCIS
	additionalRecordTypes-ME			[3]	MarketSpecificRecordTypes,	-- see chapter 5.4.2
-- inside the record content:
	standardExtensions-ME				[4]	NULL,					-- NOT USED for RUCIS
	recordExtensions-ME				[5]	CommonCDE,				-- see chapter 5.4.3
	functionalInformation-ME				[6]	NULL,					-- NOT USED for RUCIS
	serviceSpecificINInformation-ME		[7]	NULL					-- NOT USED for RUCIS
}


MarketSpecificRecordTypes	::=	CHOICE {
	dB-Subscriber-RecordType			[0]	CallRecord,
	dB-Trunk-RecordType				[1]	CallRecord,
	dB-SS-RecordType					[2]	CallRecord,
	dB-BCG-RecordType				[3]	CallRecord,
	dB-IN-RecordType					[4]	CallRecord,
	dBO-RecordType					[5]	CallRecord, -- Not used for RUCIS
	dB-A-Subscriber-RecordType			[6]	CallRecord, -- Not used for RUCIS
	dB-B-Subscriber-RecordType			[7]	CallRecord, -- Not used for RUCIS
	dB-Incoming-Trunk-RecordType		[8]	CallRecord, -- Not used for RUCIS
	dB-Outgoing-Trunk-RecordType		[9]	CallRecord, -- Not used for RUCIS
	dB-A-BCG-Subscriber-RecordType		[10]	CallRecord, -- Not used for RUCIS
	dB-B-BCG-Subscriber-RecordType		[11]	CallRecord, -- Not used for RUCIS
	-- ...
	-- market specific record types to be added here starting with tag 12
	-- ...
	marketSpecificRecordType0			[12]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType1			[13]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType2			[14]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType3			[15]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType4			[16]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType5			[17]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType6			[18]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType7			[19]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType8			[20]	CallRecord, -- Not used for RUCIS
	marketSpecificRecordType9			[21]	CallRecord  -- Not used for RUCIS
}


CommonCDE				::=	SEQUENCE {
--	The following extensions are considered as market specific (CDE):
	cDE					[0]	CDE					OPTIONAL,
--	The following extensions are considered as common:
	carrierSelection		[1]	CarrierSelection		OPTIONAL,
	tariffCode				[2]	TariffCode			OPTIONAL,
	transmissionMedium	[3]	TransmissionMedium	OPTIONAL,
	bCGSpecificInfo		[4]	BCGSpecificInfo		OPTIONAL,
	additionalINSpecificInfo	[5]	AdditionalINSpecificInfo	OPTIONAL,
	networkProviderId		[6]	NetworkProviderId		OPTIONAL,
	testIdentification		[7]	TestIdentification		OPTIONAL,
	connectedOperator		[8]	ConnectedOperator		OPTIONAL
}


CDE						 ::= SEQUENCE {
	typeOfTraffic			[0]	TypeOfTraffic		OPTIONAL,
	tariffRegimeCode		[1]	TariffRegimeCode	OPTIONAL
}


TypeOfTraffic ::= ENUMERATED {
	local			(0),
	Zonal		(1),
	interzonal		(2),
	international	(3),
	facility		(4)
}


TariffRegimeCode ::=  INTEGER 

CarrierSelection			::=	SET {
	carrierPreselectionCode	[0]	CarrierAccessCode			OPTIONAL,
	carrierSelectionCode	[1]	CarrierAccessCode			OPTIONAL,
	carrierDependentRouting	[2]	BOOLEAN				OPTIONAL
}
CarrierAccessCode		::=	SEQUENCE {
	carrierDiscriminatorDigits	[0]	OCTET STRING			OPTIONAL,
	carrierIdentificationCode	[1]	OCTET STRING			OPTIONAL
}


TariffCode				::=	OCTET STRING 

TransmissionMedium		::=	SEQUENCE {
	tMR					[0]	TMR				OPTIONAL,
	tMU					[1]	TMU				OPTIONAL
}

TMR						::=	OCTET STRING 
TMU						::=	OCTET STRING 


BCGSpecificInfo				::=	SEQUENCE {
	bCGIdentity				[0]	BCGIdentity,
	accessCode				[1]	AccessCode						OPTIONAL,
	accountCode				[2]	AccountCode						OPTIONAL,
	callingPtyPrivateNo			[3]	CallingPartyPrivateNumber			OPTIONAL,
	calledPtyPrivateNo			[4]	CalledPartyPrivateNumber			OPTIONAL,
	redirectingPtyPrivateNo		[5]	RedirectingPartyPrivateNumber		OPTIONAL,
	redirectionPtyPrivateNo		[6]	RedirectionPartyPrivateNumber		OPTIONAL,
	originalCalledPtyPrivateNo	[7]	OriginalCalledPartyPrivateNumber		OPTIONAL,
	cgPtyPrivateNoNotScreened	[8]	CallingPartyPrivateNumberNotScreened	OPTIONAL
}

BCGIdentity							::=	OCTET STRING
AccessCode							::=	OCTET STRING
AccountCode							::=	OCTET STRING


CallingPartyPrivateNumber				::=	Number
CalledPartyPrivateNumber				::=	Number
RedirectingPartyPrivateNumber			::=	Number
RedirectionPartyPrivateNumber			::=	Number
OriginalCalledPartyPrivateNumber		::=	Number
CallingPartyPrivateNumberNotScreened	::=	Number


AdditionalINSpecificInfo	::=	SET {
	transparantParameter1		[0]	TransparantParameter1			OPTIONAL,
	transparantParameter2		[1]	TransparantParameter2			OPTIONAL,
	transparantParameter3		[2]	TransparantParameter3			OPTIONAL,
	iNSurcharge				[3]	INSurcharge					OPTIONAL,
	iNProvidedDestinationNumber	[4]	INProvidedDestinationNumber		OPTIONAL,
	iNCause					[5]	INCause						OPTIONAL,
	freeFormatData			[6]	FreeFormatData				OPTIONAL,
	iNChargeRateModulator		[7]	INChargeRateModulator			OPTIONAL
}

TransparantParameter1		::=	OCTET STRING
TransparantParameter2		::=	OCTET STRING
TransparantParameter3		::=	OCTET STRING
INSurcharge				::=	ChargingInformation
INProvidedDestinationNumber	::=	Number
INCause					::=	CHOICE {
	releaseCauseSCP			[0]	INTEGER,
	releaseCauseSSP			[1]	INTEGER,
	sCPProvidedCause			[2]	INTEGER
}
FreeFormatData			::= SEQUENCE OF OCTET STRING
INChargeRateModulator	::= INTEGER


TestIdentification			::=	OCTET STRING

ConnectedOperator		::=	SEQUENCE {
	connectedOperatorIncoming	[0]	OperatorId		OPTIONAL,
	connectedOperatorOutgoing	[1]	OperatorId		OPTIONAL
}
OperatorId				::=	OCTET STRING

PersonalUserId			::=	OCTET STRING 

ServiceSpecificINInformation	::=	ManagementExtensions

CDRPurpose				::=	INTEGER 
NetworkProviderId			::=	VisibleString
FileName				::=	NameType

END
}
