package Broadworks;
use base 'Source';
use strict;

sub readFile {
  my $self = shift();
  my $process = shift();
  until (eof($$self{filehandle})) {
    $process->($self->readRecord());
    $self->{fileblocks}++}}

sub readRecord {
  my $self = shift();
  my $rec = BroadworksRecord->new($$self{filehandle})}

sub tablename {
  "BROADWORKS"}

sub fields {
  qw/caller peer calltime duration filial sid addr dnset/}

1;
###########################################################################
package BroadworksRecord;
use base 'CDR';
use fields qw/b1 b2 b3 calltime caller peer b4 b5 b6 duration b7 b8 b9 b10 filial b11 b12 b13 b14 b15 sid callerid b16 dialed b17 b18 addr dnset b19 b20/; 

#0;0;1;03.11.2009 09:14:32;7232700261;7233640676;NO;0;0 ;32;	  0;0;0;1;   12;   12; 7232700261;20091103091432.633;Yes;20091103091504.644;1417278068@sip.telecom.kz;+77232700261; ;+77232700261;87233640676;87233640676;interlat;10.14.0.38:5060;SP_USKEMEN;to;+77233640676
#b1b2b3 calltime	    caller     peer      b4 b5b6 duration b7b8b9b10 filial b11 b12	  b13		     b14  b15		    sid				callerid	b16	   dialed	b17	    b18	    addr	     dnset    b19 b20
sub new {
  my $self = shift();
  my $fh    = shift();

  my ($buf, $tmp);

  $buf = readline $fh;
  chomp($buf);
  my $self = fields::new($self) unless ref $self;

  @$self{qw/b1 b2 b3 calltime caller peer b4 b5 b6 duration b7 b8 b9 b10 filial b11 b12 b13 b14 b15 sid callerid b16 dialed b17 b18 addr dnset b19 b20/}=
        split ";", $buf;

  return $self}

sub calltime {
  my $self = shift;
  $$self{calltime} =~ /(\d\d)\.(\d\d)\.(\d\d\d\d)\s(\d\d\:\d\d\:\d\d)/;
  join('-',$3,$2,$1) . " $4"}

1;