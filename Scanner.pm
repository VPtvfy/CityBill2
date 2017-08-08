package Scanner;
use strict;
use File::Copy;
use CityBill;
use Source;
our $AUTOLOAD;

sub new {
  my $class = shift();
  my $self = {@_};
  bless $self, $class;

  $self}

sub enumerate {
  my $self = shift();
  my $pattern = $self->GET_PATTERN;
  my @files = $self->ls;

#  my $pattern = $self->pattern;
  $pattern .= "|" . $self->GET_SUBDIR if ($self->GET_SUBDIR ne '');

  my $storage = CityBill::storage();

#  grep {!exists $oldfiles{uc $_}} (grep /$pattern/i, @files)

  @files = grep /$pattern/i, @files;
  my %oldfiles;

  @oldfiles{map(uc, $storage->filesFromATS($self->STATION))} = ();
  my @nefiles = ();

  for my $file (@files){
    my $file1 = $file;
    $file =~ s/\.CA[LPD]//i;
    push @nefiles, $file1 if (!exists $oldfiles{uc $file})}
  my $files    = @files+0;
  my $newfiles = @nefiles+0;
  Logger::write ($self->STATION . ": Total remote files: $files, new files: $newfiles");
  @nefiles}


sub AUTOLOAD {
  my $self = shift;
  my $type = ref($self)  or Logger::die "$self is not an object";

  my $name = $AUTOLOAD;
  $name =~ s/.*://;

  return undef unless (exists $self->{$name});

  if (@_) {
    return $$self{$name} = shift} 
  else {
    return $$self{$name}}}  


sub isfolder {
  0}

sub post_process {
  my $self = shift;
  my $name = shift;
  copy($name, $self->HOMEDIR . $name);}

sub process {
  my $self = shift;
  my $name = shift;
  
  my (undef,undef,undef,undef,$m,$y) = localtime();
  $y += 1900;
  $m ++;
  my $year = sprintf "%d_%02d",$y,$m;
  my $storage = CityBill::storage;
  my $file = Source::autodetect(filename => $name, year => $year);
  $storage->store($file, $self->STATION, $self->substation);

  #$file->storeFile;
  $self->post_process($name)}

sub scan {
  my $self = shift;
  my @list = $self->enumerate;

  foreach my $file (@list) {
    if ($self->isfolder($file)) {
      my $station = $self->STATION;
      my $homedir = $self->HOMEDIR;
      $$self{HOMEDIR} .= "$file\\";
      my $substation = $file;
      my $pattern = $self->GET_SUBDIR;
      $substation =~ s/$pattern/$1/;
      $$self{substation} = $substation;
#      $substation = $self->station . "-$substation";
#      $$self{station} = $substation;
      $self->chdir($file);
      $self->scan;
      $self->chdir("..");
#      $$self{station} = $station;
      $$self{HOMEDIR} = $homedir;
    } else {
      $self->get($file, "$file.tmp");
      sleep(10);
      $self->get($file,$file);

      $self->process($file) if ((-s $file) == (-s "$file.tmp"));
      Logger::write("Scanner: file '$file' from station '" . $self->STATION . "' loaded");
      unlink "$file.tmp";
      unlink $file
    }}}

1;
