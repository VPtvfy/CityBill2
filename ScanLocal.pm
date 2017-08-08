package ScanLocal;
use strict;
use base 'Scanner';
use File::Copy;
use CityBill;                 
use Source;

sub new {
  my $class = shift();
  my $self = {@_};
  bless $self, $class;

  $$self{src} = '';
  $$self{src} = $self->GET_REMOTEDIR if ($self->GET_REMOTEDIR);
  $self}

sub chdir{
  my $self = shift;
  my $dir  = shift;
  my $src = $self->src;
  if ($dir eq '..'){
    $src =~ s/(.+)\\[^\\\/\:\*\?\"\<\>\|]+$/$1/}
  else {
    $src .= "\\$dir"}
  $$self{src} = $src}

sub isfolder{ 
  my $self = shift;
  my $name = shift;
  (-d $self->src . "\\" . $name)}

sub ls {
  my $self = shift();
  my $dir;
  opendir($dir,$self->src) or Logger::die("opendir failed");
  my @files = readdir($dir) or Logger::die("readdir failed");
  closedir($dir);
  @files}

sub get {
  my $self = shift;                  
  my $sorc = shift;
  my $dest = shift;
  $sorc = $self->src . "\\" . $sorc;
  copy($sorc,$dest) or Logger::die("get failed")}

sub DESTROY {}

1;