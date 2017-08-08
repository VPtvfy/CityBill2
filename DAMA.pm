package DAMA;
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
  my $rec = DAMARecord->new($$self{filehandle})}

sub ftime {
  my $self = shift;
  my $ftime = $self->filebasename;
  if ($ftime =~ /^dm(\d\d\d\d)_(\d\d)_(\d\d)\.[tTxX]{3}/){
  	return join("-",$1,$2,$3) . " 00:00:00"}
  elsif($ftime =~ /^dm(\d\d\d\d)(\d\d)(\d\d)_\d{8}\.[tTxX]{3}/){
  	return join("-",$1,$2,$3) . " 00:00:00"}
  else{
  	return $self->filetime}}

sub tablename {
  "DAMA"}

sub fields {
  qw/X31 trunk_in X33 trunk_out X35 caller calltime peer duration X36 X37 X38/}

1;
###########################################################################
package DAMARecord;
use base 'CDR';
use fields qw/X31 trunk_in X33 trunk_out X35 caller date time _date _time peer duration X36 X37 X38/; 

sub new {
  my $self = shift();
  my $fh    = shift();

  my ($buf, $tmp);

  $buf = readline $fh;
  chomp($buf);
  my $self = fields::new($self) unless ref $self;

  @$self{qw/X31 trunk_in X33 trunk_out X35 caller date time _date _time peer duration X36 X37 X38/}=
        split ",", $buf;

  return $self}

sub calltime {
  my $self = shift;
  my $date = $$self{date};
  $date =~ /(\d\d).(\d\d).(\d\d\d\d)/;
  $date = join('-',$3,$2,$1);
  "$date " . $$self{time}}

1;