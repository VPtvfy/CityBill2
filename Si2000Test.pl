use strict;
use Si2000;

my %handles;
my ($error,$errstr);
my $filename = "F:\\xampp\\htdocs\\projects\\citybill2\\Ama\\i525020100301010036.ama";
my $fh = openFile($filename);


#(my $year, my $month, my $day, my $hour, my $min, my $sec) = Date::Calc::Delta_YMDHMS(2010, 4, 6, 11, 0, 30, 2010, 4, 6, 11, 0, 31);
#printf "%02u-%02u-%02u %02u:%02u:%02u\n", $year, $month, $day, $hour, $min, $sec;


my ($buf, $src) = ('','');

read $fh, $buf, 200;

if ($buf =~ /^\xC8|^\xD2|^\xD3|^\xD4/)
{
	print "Si2000\n";
	Si2000::processFile($filename);
}
else
{
	print "Unknown\n";
}

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
    $tmp = tempFile("$base.XXXXXX") or die("Can't create temporary file for gzip '$file'",5);
    return if ($error);
    system "gzip -d -c $file > $tmp";}

  open($fh, "<", ($tmp || $file)) or die("Can't open file '$file' for read",5);
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
