package CSV;
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
  my $rec = CSVRecord->new($$self{filehandle})}

sub ftime {
  my $self = shift;
  $self->filetime}

sub tablename {
  "CSV"}

sub fields {
  qw/b1 b2 sourcetype calltime caller peer duration factor b3 duration_m duration_p b4 b5 b6/}

1;
###########################################################################
package CSVRecord;
use base 'CDR';
use fields qw/b1 b2 sourcetype calltime caller peer factor b3 duration_m duration duration_p b4 b5 b6/; 

sub new {
  my $self = shift();
  my $fh    = shift();

  my ($buf, $tmp);

  $buf = readline $fh;
  chomp($buf);
  my $self = fields::new($self) unless ref $self;

  @$self{qw/b1 b2 sourcetype calltime caller peer factor b3 duration_m duration duration_p b4 b5 b6/}=
        split ";", $buf;

  return $self}

sub calltime {
  my $self = shift;
  $$self{calltime} =~ /(\d\d)\.(\d\d)\.(\d\d\d\d)\s(\d\d\:\d\d\:\d\d)/;
  join('-',$3,$2,$1) . " $4"}

1;