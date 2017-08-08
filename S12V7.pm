package S12V7;
use base 'Source';
use strict;

sub readFile {
  my $self = shift();
  my $process = shift();
  our $year = shift();

  until (eof($$self{filehandle})) {
    my $buffer;
    read $$self{filehandle}, $buffer, 8;
    for (1..34) {
      my $rec = $self->readRecord();
      $process->($rec) if ($rec->MM != 0 && $rec->DD != 0)}
    $self->{fileblocks}++}}

sub filerecords {
  my $self = shift;
  $self->{fileblocks} * 34}

sub ftime {
  my $self = shift;
  my $ftime = $self->filebasename;
  if ($ftime =~ /^(ats|ATS)\d+\-(\d\d)(\d\d)(\d\d)\-(\d\d)(\d\d)(\d\d)\.(tape|TAPE|02x|02X)/){
    my $yer = $2 < 70 ? $2 + 2000 : $2 + 1900;   
    return join("-",$yer,$3,$4) . " " . join(":",$5,$6,$7)}
  elsif ($ftime =~ /^(tt|TT)(\d\d\d\d)_{0,1}(\d\d)_{0,1}(\d\d).+(02x|02X)/){
    return join("-",$2,$3,$4) . " 00:00:00"}
  $self->filetime}

sub readRecord {
  my $self = shift();
  my $rec = V7Record->new($$self{filehandle},$self->year())}

sub tablename {
  "S12V7"}

sub fields{
  qw/calltype trunk_in trunk_out caller peer calltime duration abontype pulses conntype recs recindicator midnightwalk bearer/}

1;
###########################################################################
package V7Record;
use base 'CDR';
use fields qw/calltype abontype caller peer DD MM hh mm ss duration_hours
     	    duration_mins duration_secs pulses conntype recs recindicator 
            midnightwalk trunk_in trunk_out bearer year/; 

sub convert (\$) {
  ${$_[0]} =~ tr [\360-\371] [0-9]}

sub new {
  my $self = shift;
  my $fh    = shift;
  my $year  = shift;
  my ($buf, $tmp);

  read $fh, $buf, 60;
  $tmp = substr $buf, -5, 4;
  convert $buf;
  substr($buf, -5, 4) = $tmp;

#  my $self = fields::phash(
#	[qw/calltype abontype caller peer DD MM hh mm ss duration_hours
#     	    duration_mins duration_secs pulses conntype recs recindicator 
#            midnightwalk trunk_in trunk_out bearer year/], 
#        [(unpack "A1A3A8A15A2A2A2A2A2A2A2A2A6A2A2A1A1H4H4A1", $buf), $year]);
  my $self = fields::new($self) unless ref $self;

  @$self{qw/calltype abontype caller peer DD MM hh mm ss duration_hours
     	    duration_mins duration_secs pulses conntype recs recindicator 
            midnightwalk trunk_in trunk_out bearer/} = unpack "A1A3A8A15A2A2A2A2A2A2A2A2A6A2A2A1A1H4H4A1", $buf;
  $$self{year}= $year;
  
  $$self{caller} =~ tr/\306//d;
  $$self{caller} =~ s/^3(\d{7})$/723$1/;
  $$self{caller} =~ s/^2(\d{7})$/722$1/;
  
  $$self{peer} =~ tr/\306//d;
#  bless $self, $class
  return $self}

sub calltime {
  my $self = shift();

  my ($lyear,$lmon) = split('_',$$self{year});
  $lyear -= ($lmon < $self->MM) ? 1 : 0;
  sprintf("$lyear-%02u-%02u %02u:%02u:%02u", @$self{qw/MM DD hh mm ss/})}

sub duration {
  my $self = shift();
  $$self{duration_hours} * 3600 + $$self{duration_mins} * 60 + $$self{duration_secs}}