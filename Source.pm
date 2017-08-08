package Source;
use strict;

use Oversea;
use TPLAK;
use DAMA;
use S12V5;
use S12V7;
use S12WR1A;
use SoftX3000v5;
use CSV;
use unknown;
use Logger;
use SI2000;

#use vars qw($error,$errstr);

use overload ('""' => 'asString');

my @tmpfiles;
my %handles;
my ($error,$errstr);

sub new {
  my $class = shift();
  my $self = {@_};
  bless $self, $class;

  my (undef,undef,undef,undef,$cmon, $cyear,undef,undef,undef) = localtime ();

  if(!($self->year =~ /^\d\d\d\d\_\d\d/)) {
    my $dt = $self->filename;
    $dt =~ m/^[Aa][Tt][Ss]\d+\-(\d\d)(\d\d)\d\d\-/;
    $dt =~ m/^[Tt][Tt]\d\d(\d\d)(\d\d)/;
    $dt = "20$1_$2";
    $self->{year} = ($dt =~ /^\d{4}\_\d\d/) ? ((substr($dt,0,2) + 2000) . "_" . substr($dt,2,2)) : (($cyear + 1900) . "_" . sprintf("%02i",$cmon+1));
  }

  $$self{filehandle} = openFile($self->filename);
  $self->{fileblocks}=0;
  $self->{filerecords}=0;

  return $self}


sub DESTROY {
  my $self = shift();
  close($$self{filehandle})}

sub seterr {
  my $errstr = shift;
  my $err = shift;
  Logger::write($errstr);
  $error = $err;}

sub error {
  my $self = shift;
  #  Possible values:
  #  5 - filesystem problem
  #  6 - file structure error
  #  7 - bad size of file
  #  9 - file already exists in database
  ($self->{error} ? $self->{error} : 0)}

sub storeFile {
  my $self = shift();
  my $year = shift();
  
  $self->readFile(sub {print "@_\n"},$year);
  print "Blocks: " . $self->fileblocks;
  print "\nRecords: " . $self->filerecords;}

sub fileblocks {
  my $self = shift;
  $self->{fileblocks}}
  
sub filerecords {
  my $self = shift;
  $self->{fileblocks}}

sub filetime {
  my $self = shift();
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
		$atime,$mtime,$ctime,$blksize,$blocks) = stat $$self{filehandle};

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime($ctime);

  sprintf("%04d-%02d-%02d %02d:%02d:%02d", 1900 + $year,  $mon + 1, $mday, $hour, $min, $sec)}

sub ftime {
  my $self = shift;
  $self->filetime}

sub filebasename {
  use File::Basename;
  my $self = shift();
  basename($self->{filename})}

sub filesize {
  my $self = shift();
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat $$self{filehandle};
  $size}

sub year {
  my $self = shift();
  $self->{year}}

sub param {
  my $self = shift();
  $self->{param}}
  
sub filename {
  my $self = shift;
  $self->{filename}}

sub md5sum {
  use Digest::MD5;

  my $self = shift();
  my $pos = tell $$self{filehandle};

  seek $$self{filehandle}, 0, 0;
  my $digest = Digest::MD5->new->addfile($$self{filehandle})->hexdigest;
  seek $$self{filehandle}, 0, $pos;

  $digest}

sub asString {
  my $self = shift();
  join ":", $self->filesize, $self->md5sum}

sub openFile {
  use File::Basename;
  use File::Temp qw(mktemp);
  
  my $file = shift();
  my $base = basename($file); 
  my $fh;
  my $tmp;

  if(exists $handles{$file}) {
    seek $handles{$file}, 0, 0;
    return $handles{$file}} 

  if ($base =~ /\.gz$/) {
    $tmp = tempFile("$base.XXXXXX") or seterr("Can't create temporary file for gzip '$file'",5);
    return if ($error);
    system "gzip -d -c $file > $tmp";}

  open($fh, "<", ($tmp || $file)) or seterr("Can't open file '$file' for read",5);
  binmode $fh;

  return if($error);

  my $buf;
  read($fh,$buf,100) or seterr("Can not read from file '$file'",5);
  return if ($error);
  seek $fh,0,0;
  
  if ($buf =~ /^\-BDAT\-.*\-EDAT\-/) {
    my $tfh = extractFileFromTape($fh,$base);
    $fh = $tfh if (!$error)}
  

  $handles{$file} = $fh;
  $fh}

sub fread {
  my $fh = shift();
  my $len = shift();
  my $tmp;
  read($fh,$tmp,$len) if !eof $fh;
  $tmp}

sub readTapeBlock {
  my $f = shift();
  my ($length, $text, $declength);
  my $tmp = fread($f,6);
  return 0 if ($tmp eq "-FILE-");
  seterr("readTapeBlock -BDAT- expected",6) if ($tmp ne "-BDAT-");
  return if ($error);
  $length=fread($f,2);
  $declength=ord(substr($length,0,1))+ord(substr($length,1,1))*256;
  $text=fread($f,$declength);
  seterr('readTapeBlock (lengths not concurred)',6) if ($length ne fread($f,2));
  return if ($error);
  seterr('readTapeBlock (EDAT expected, but not found)',6) if (fread($f,6) ne "-EDAT-");
  return if ($error);
  $text;}

sub expect{
  my $fh = shift();
  my $exp = shift();
  (fread($fh,length($exp)) ne $exp) ? 0 : 1}

sub extractFileFromTape {

  my $fh = shift();
  my $filename = shift();
  $filename =~ s/\.gz|\.tape//g;

  my $tmp = tempFile("$filename.XXXXX");

  my $tfh;
  open $tfh, "> $tmp";

  binmode $tfh;

  readTapeBlock($fh);	#	VOL1
  readTapeBlock($fh);	#	HDR1
  readTapeBlock($fh);  	#	HDR2
  return if ($error);
  if (!expect($fh,"-FILE-")) {
  	seterr("-FILE- expected, but not found",6);
  	return}	#	DATA
  while(my $txt = readTapeBlock($fh)){
  	return if ($error);
    $txt =~ tr/[\x00-\xFF]/[\x00\x80\x40\xC0\x20\xA0\x60\xE0\x10\x90\x50\xD0\x30\xB0\x70\xF0\x08\x88\x48\xC8\x28\xA8\x68\xE8\x18\x98\x58\xD8\x38\xB8\x78\xF8\x04\x84\x44\xC4\x24\xA4\x64\xE4\x14\x94\x54\xD4\x34\xB4\x74\xF4\x0C\x8C\x4C\xCC\x2C\xAC\x6C\xEC\x1C\x9C\x5C\xDC\x3C\xBC\x7C\xFC\x02\x82\x42\xC2\x22\xA2\x62\xE2\x12\x92\x52\xD2\x32\xB2\x72\xF2\x0A\x8A\x4A\xCA\x2A\xAA\x6A\xEA\x1A\x9A\x5A\xDA\x3A\xBA\x7A\xFA\x06\x86\x46\xC6\x26\xA6\x66\xE6\x16\x96\x56\xD6\x36\xB6\x76\xF6\x0E\x8E\x4E\xCE\x2E\xAE\x6E\xEE\x1E\x9E\x5E\xDE\x3E\xBE\x7E\xFE\x01\x81\x41\xC1\x21\xA1\x61\xE1\x11\x91\x51\xD1\x31\xB1\x71\xF1\x09\x89\x49\xC9\x29\xA9\x69\xE9\x19\x99\x59\xD9\x39\xB9\x79\xF9\x05\x85\x45\xC5\x25\xA5\x65\xE5\x15\x95\x55\xD5\x35\xB5\x75\xF5\x0D\x8D\x4D\xCD\x2D\xAD\x6D\xED\x1D\x9D\x5D\xDD\x3D\xBD\x7D\xFD\x03\x83\x43\xC3\x23\xA3\x63\xE3\x13\x93\x53\xD3\x33\xB3\x73\xF3\x0B\x8B\x4B\xCB\x2B\xAB\x6B\xEB\x1B\x9B\x5B\xDB\x3B\xBB\x7B\xFB\x07\x87\x47\xC7\x27\xA7\x67\xE7\x17\x97\x57\xD7\x37\xB7\x77\xF7\x0F\x8F\x4F\xCF\x2F\xAF\x6F\xEF\x1F\x9F\x5F\xDF\x3F\xBF\x7F\xFF]/;
    print $tfh $txt;}
  close $tfh;
  open $tfh,"< $tmp";

  binmode $fh;

  $tfh}

sub tempFile {
  use File::Temp qw(tempfile);
  use File::Spec;
  my (undef, $tmp) = tempfile(@_, OPEN => 0,  DIR => File::Spec->tmpdir());
  push @tmpfiles,$tmp;
  $tmp}

sub autodetect {
  my %params = @_;
  my $filename = $params{filename};

  my $fh = openFile($filename);
  return new unknown(%params,error => $error) if ($error);
  my ($buf, $src) = ('','');

  read $fh,$buf,200;

  if ($buf =~ /^\d\d\d\d\.\d\d\.\d\d \d\d:\d\d:\d\d \d\d\d\d\.\d\d\.\d\d \d\d:\d\d:\d\d \d+ \d\d\d\d\d\d\d (\d+|N)\r\n/) {
	$src = 'TPLAK'}
  elsif ($buf =~ /^[^,]+,.+,\d\d.\d\d.\d\d\d\d,\d\d:\d\d:\d\d,\d*,\d+,\d+,\d+,\d+,/) {
	$src = 'DAMA'}
  elsif ($buf =~ /^\d+;\d+;\d+;\d\d.\d\d.\d\d\d\d \d\d:\d\d:\d\d;.*;.*;/) {
	$src = 'CSV'}
  elsif ($buf =~ /^HDRTXDAUT/) {
	$src = 'S12V5';
	if ((-s $fh) % 2048 != 0){
	  Logger::write("bad size of: $filename");
	  return $src->new(%params,error => 7)}}
  elsif ($buf =~ /^\xF0\xF2\xF0\xF0\xF0\xF0\xF0\xF0/) {
	$src = 'S12V7';
  	if ((-s $fh) % 2048 != 0){
	  Logger::write("bad size of: $filename");
	  return $src->new(%params,error => 7)}}
  elsif ($buf =~ /^\x30\x80\xA0\x80\x04/) {
	$src = 'S12WR1A'}
  elsif ($buf =~ /^.{4}(\x0B|\x16)(\x01|\xFF\x55)/s){
  	$src = 'SoftX3000v5'}
  elsif ($buf =~ /^\xC8|^\xD2|^\xD3|^\xD4/){
    $src = 'SI2000'}
  elsif ((-s $fh) % 154 == 0) {
	$src = 'Oversea'}
  else {
    $src = 'unknown';
    Logger::write("Unknown type of file: $filename");
    Logger::write("buffer = |$buf|");
    return $src->new(%params,error => 8)}
  $src->new(%params)}

END {
  foreach my $file (@tmpfiles) {
  unlink $file}}
 
1;