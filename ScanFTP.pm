package ScanFTP;
use strict;
use base 'Scanner';
use Net::FTP;
use File::Copy;
use CityBill;                 
use Source;

sub new {
  my $class = shift();
  my $self = {@_};
  bless $self, $class;

  my $src = Net::FTP->new($self->GET_HOSTNAME, Debug => 0) or Logger::die("Cannot connect to " . $self->GET_HOSTNAME);

  $src->login($self->GET_USERNAME,$self->GET_PASSWORD) or Logger::die("Cannot login ", $src->message);

  if ($self->GET_REMOTEDIR) {
    $src->cwd($self->GET_REMOTEDIR) or Logger::die("Cannot change working directory ", $src->message)}

  $src->binary;	

  $$self{src} = $src;	
  
  $self}

sub chdir{
  my $self = shift;
  my $dir  = shift;
  my $src = $self->src;
  $src->cwd($dir)}

sub isfolder{ 
  my $self = shift;
  my $file = shift;
  my @list = $$self{src}->dir or Logger::die("dir failed " . $$self{src}->message);
  my %arr = map {split /\s+/; @_[8,0]} @list;
  $arr{$file} =~ /d.{9}/}

sub ls {
  my $self = shift;
  my @list = $$self{src}->dir or Logger::die("dir failed " . $$self{src}->message);
  map {split /\s+/; $_[8]} @list}

sub get {
  my $self = shift;
  my $ftp = $self->src;

  $ftp->get(@_) or Logger::die("get failed ", $ftp->message)}

sub DESTROY {
  my $self = shift;
  $$self{src}->quit}

1;