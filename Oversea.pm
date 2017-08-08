package Oversea;
use base 'Source';
use strict;

sub readFile {
  my $self = shift();
  my $process = shift();
  until (eof($$self{filehandle})) {
    my $rec = $self->readRecord(); 
    
        # обрабатываем только записи у которых Ticket Type == 1 (Detailed ticket)
        # и только внутренние (Intra-office) call type == 1,
        # либо исходящие (Outgoing from office) call type == 3
	#if ($rec->tickettype == 1 && ($rec->calltype == 1 || $rec->calltype == 3))}}
	if ($rec->tickettype eq '01' || $rec->tickettype eq '55') {
	  $process->($rec);
	  $self->{fileblocks}++}}}

sub readRecord {
  my $self = shift();
  my $rec = OverseaRecord->new($$self{filehandle})}

sub ftime {
  my $self = shift;
  my $ftime = $self->filebasename;
  return $self->filetime if (!($ftime =~ /^(\d\d\d\d)(\d\d)(\d\d)\d+\.(bil|BIL)/));
  join("-",$1,$2,$3) . " 00:00:00"}

sub tablename {
  "OVERSEA"}

sub fields{
  qw/sn tickettype recindicator midnightwalk freeflag callattempt payer calltime 
            duration 
            chargingDNS charging
            callerDNS caller
            connectedDNS connected
            peerDNS peer
	    CNXGroup CCNXnum PCNXgroup 
	    cmodnumber pmodnumber 
	    trunk_in trunk_out subroute_in subroute_out 
	    cdtype pdtype 
	    cpnum ppnum 
	    ccat pcat 
	    srvtype
	    calltype
	    suppsrvtype
	    pulses
	    bearer/}

1;

#########################################################################
package OverseaRecord;
use base 'CDR';
use fields qw/sn tickettype crc bf1
            YY MM DD hh mm ss 
            duration caller_seizure_duration called_seizure_duration 
            bf2 bf3 bf4
        chargingDNS charging
        callerDNS caller
        connectedDNS connected
        peerDNS called
	        dialed 
	        CNXGroup cCNXnum pCNXnum 
	        cmodnumber pmodnumber 
    	    trunk_in trunk_out subroute_in subroute_out 
	    cdtype pdtype
	    cpnum ppnum 
	    ccat pcat 
	    calltype srvcalltype
	        suppsrvtype
	        ChargingCase Tariff 
	        pulses fee balance
	        bearer
	    bf5/;
use POSIX ('ceil');

sub new {
  my $self = shift();
  my $fh    = shift();

  my ($buf, $tmp);

  read $fh, $buf, 154;

  my $self = fields::new($self) unless ref $self;

  @$self{qw/sn tickettype crc bf1
            YY MM DD hh mm ss 
            duration caller_seizure_duration called_seizure_duration 
            bf2 bf3 bf4
        chargingDNS charging
        callerDNS caller
        connectedDNS connected
        peerDNS called
	        dialed 
	        CNXGroup cCNXnum pCNXnum 
	        cmodnumber pmodnumber 
    	    trunk_in trunk_out subroute_in subroute_out 
	    cdtype pdtype
	    cpnum ppnum 
	    ccat pcat 
	    calltype srvcalltype
	        suppsrvtype
	        ChargingCase Tariff 
	        pulses fee balance
	        bearer
	    bf5/} = unpack 
           "VCCv
            CCCCCC
            VVV
            CCC
        CH[20]
        CH[20]
        CH[20]
        CH[20]
            H[24]
            vH[8]H[8]
            CC
            H[4]H[4]H[4]H[4]
        CC
        vv
        CC
        HH
	        C
     	    vv
    	    VVV
	        C
        A*", $buf;

  map {tr/f//d} @$self{'caller', 'called', 'cCNXnum', 'pCNXnum'};

  $$self{caller} =~ s/^3232(\d{6})$/$1/;
  $$self{caller} =~ s/^32323232(\d{6})$/$1/;
  $$self{caller} =~ s/^7232(\d{6})$/$1/;
  $$self{caller} =~ s/^72327232(\d{6})$/$1/;

  return $self}

sub calltime {
  use Date::Calc;
  my $self = shift();
  sprintf "20%02u-%02u-%02u %02u:%02u:%02u", Date::Calc::Add_Delta_YMDHMS(@$self{qw/YY MM DD hh mm ss/},0,0,0, 0,0, - $self->duration)}

sub duration {
  my $self = shift();
  ceil($$self{duration} / 100)}

sub peer {
  my $self = shift();
  $$self{called}}

sub cpnum {
  my $self = shift;
  sprintf "%04X", $$self{cpnum}}

sub ppnum {
  my $self = shift;
  sprintf "%04X", $$self{ppnum}}

sub tickettype {
  my $self = shift;
  sprintf "%02X", $$self{tickettype}}

sub recindicator {
  my $self=shift();
  $$self{bf1} >> 14}

sub midnightwalk {
  my $self=shift();
  ($$self{bf1} & 8192) ? 1 : 0}

sub freeflag {
  my $self=shift();
  ($$self{bf1} & 4096) ? 1 : 0}

sub validity {
  my $self=shift();
  ($$self{bf1} & 2048) ? 1 : 0}

sub callattempt {
  my $self=shift();
  ($$self{bf1} & 1024) ? 1 : 0}

sub complaint {
  my $self=shift();
  ($$self{bf1} & 512) ? 1 : 0}

sub centercharge {
  my $self=shift;
  ($$self{bf1} & 256) ? 1 : 0}

sub pps {
  my $self=shift;
  ($$self{bf1} & 128) ? 1 : 0}

sub chargemethod {
  my $self=shift;
  (($$self{bf1} >> 5) % 4)}

sub npcall {
  my $self=shift;
  ($$self{bf1} & 16) ? 1 : 0}

sub payer {
  my $self=shift;
  $$self{bf1} % 8}

sub bf1 {
  my $self=shift();
  sprintf "%16b", $$self{bf1}}

1;