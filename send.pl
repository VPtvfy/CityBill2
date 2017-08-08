use strict;

use Digest::MD5;

use CityBill;
use Source;
use Logger;

use CGI;
my $q = new CGI;
my $allow = 0;
my @accepted_ip = qw/127.0.0.1 10.174.1.75 10.174.9.232 10.174.3.232 10.174.21.232 10.174.23.232/;

my %config = do "config.pl";

my $from_ip = $ENV{REMOTE_ADDR};

print $q->header(-charset => "Windows-1251");

foreach (@accepted_ip){
  $allow = 1 if ($from_ip eq $_)}

Logger::die("unrestricted access from ip " . $from_ip) if (!$allow);

my $ats = $q->param('user');
my $fname = $q->param('file');
my $md5sum1 = $q->param('md5sum');

my $filename = $config{'upload_dir'} . "$ats\\$fname";

Logger::die("Файл $filename не найден") if (!-f $filename);
open(FILE, $filename);
binmode(FILE);
my $md5sum = Digest::MD5->new->addfile(*FILE)->hexdigest . " *$fname";
close(FILE);
Logger::die("md5 суммы не совпадают: '$md5sum' '$md5sum1'") if ($md5sum ne $md5sum1);
#name,filetime,time,ats,from_ip

my $storage = CityBill::storage;
                                   
my $file = Source::autodetect(filename => $filename);

$storage->store($file,$ats);

print $file->error() ? $file->error() : "OK";
