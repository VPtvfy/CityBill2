package ScanShare;
use strict;
use base 'Scanner';
use File::Copy;
use CityBill;
use Source;

use Win32::NetResource qw/GetUNCName AddConnection CancelConnection/;
use Win32API::File qw/ CopyFile fileLastError /;

sub new {
  my $class = shift();
  my $self = {@_};
  bless $self, $class;
  my $drive;

  for my $letter ('l' .. 'z' ) {
    my $mapped;
    $drive = "$letter:";
    GetUNCName( $mapped, $drive );
    last if not $mapped;
  }
  my $netuse = "net use $drive \\\\" . $self->hostname . "\\" . $self->remotedir . " " . $self->password . " /user:" . $self->hostname . "\\" . $self->username;
  system($netuse);

  $$self{driveletter} = $drive;
  $$self{src} = $drive . "\\";

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

sub DESTROY {
  my $self = shift;
  system("net use " . $self->driveletter . " /delete");}

1;