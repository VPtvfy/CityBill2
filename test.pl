use CityBill;
use Source;


my $filename = $ARGV[0] || Logger::die("usage: filename ats [year] [force|rollback]");
my $ats  = $ARGV[1] || Logger::die("usage: filename ats [year] [force|rollback]");
my $year = $ARGV[2];
my $param = $ARGV[3];

$param = ($year =~ /[a-zA-Z]+/) ? $year : $param;

my $storage = CityBill::storage;
                                   
my $file = Source::autodetect(filename => $filename, year => $year, param => $param);

#$storage->store($file,$ats);

$file->storeFile();
