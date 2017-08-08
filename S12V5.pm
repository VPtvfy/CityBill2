package S12V5;
use base 'Source';
use strict;

sub md5sum {
  my $self = shift();

  use Digest::MD5;

  my $fh = $$self{filehandle};

  my $pos = tell $fh;

  my $tmp;

  seek $fh, 0, 0;
  read $fh, my $tmp2, 58;
  read $fh, $tmp, ((-s $fh) - 2048 - 58);
  seek $fh, 0, $pos;

  Digest::MD5::md5_hex($tmp)}

sub readFile {
  my $self = shift();
  my $process = shift();
  until (eof($$self{filehandle})) {
    my $buffer;
    for (1..35) {
      my $rec = $self->readRecord();
      $process->($rec) if $rec->rectype eq 'TXD'}
    read $$self{filehandle}, my $tmp, 18;
  $self->{fileblocks}++}}

sub filerecords {
  my $self = shift;
  $self->{fileblocks} * 35}

sub ftime {
  my $self = shift;
  my $ftime = $self->filebasename;
  return $self->filetime if (!($ftime =~ /^(ats|ATS)\d+\-(\d\d)(\d\d)(\d\d)\-(\d\d)(\d\d)(\d\d)\.(tape|TAPE|02x|02X)/));
  my $year = $2 < 70 ? $2 + 2000 : $2 + 1900;   
  join("-",$year,$3,$4) . " " . join(":",$5,$6,$7)}

sub readRecord {
  my $self = shift();
  my $rec = V5Record->new($$self{filehandle})}

sub tablename {
  "S12V5"}

sub fields {
  qw/calltype caller peer calltime duration abontype pulses recindicator bearer/}

1;

###########################################################################
package V5Record;
use base 'CDR';
use fields qw/rectype caller abontype YY MM DD hh mm ss duration_hours
            duration_mins duration_secs pulses peer recindicator calltype bearer/;

sub new {
  my $self = shift;
  my $fh    = shift;

  my ($buf, $tmp);

  read $fh, $buf, 58;

  my $self = fields::new($self) unless ref $self;
  
  @$self{qw/rectype caller abontype YY MM DD hh mm ss duration_hours
            duration_mins duration_secs pulses peer recindicator calltype bearer/} = 
        unpack "A3A11A1A2A2A2A2A2A2A2A2A2A4A18A1A1A1", $buf;

  return $self}

sub fields_{
  qw/calltype caller peer calltime duration abontype pulses recindicator bearer/}

sub calltime {
  my $self = shift();
  sprintf("20%02u-%02u-%02u %02u:%02u:%02u", @$self{qw/YY MM DD hh mm ss/})}

sub duration {
  my $self = shift();
  $$self{duration_hours} * 3600 + $$self{duration_mins} * 60 + $$self{duration_secs}}