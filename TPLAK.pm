package TPLAK;
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
  my $rec = TPLAKRecord->new($$self{filehandle})}

sub tablename {
  "TPLAK"}

sub ftime {
  my $self = shift;
  my $ftime = $self->filebasename;
  return $self->filetime if (!($ftime =~ /^(\d\d)(\d\d)(\d\d)\d\d\.CA/));
  my $year = $1 < 70 ? $1 + 2000 : $1 + 1900;   
  join("-",$year,$2,$3) . " 00:00:00"}

sub fields {
  qw/caller peer calltime duration/}

1;
###########################################################################
package TPLAKRecord;
use base 'CDR';
use fields qw/date time _date _time duration caller peer/; 

sub new {
  my $self = shift();
  my $fh    = shift();

  my ($buf, $tmp);

  $buf = readline $fh;
  chomp($buf);
  my $self = fields::new($self) unless ref $self;

  @$self{qw/date time _date _time duration caller peer/}=
        split " ", $buf;

  return $self}

sub caller {
  my $self = shift;
  $$self{caller} =~ s/^2(\d{6})$/7232$1/;
  $$self{caller}}

#sub peer {
#  my $self = shift;
#  $$self{peer}}

sub calltime {
  my $self = shift;
  my $date = $$self{date};
  $date =~ tr[\.][\-];
  "$date " . $$self{time}}

sub duration {
  my $self = shift;
  +$$self{duration}}

1;