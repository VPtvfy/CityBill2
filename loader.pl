use CityBill;
use Source;


my $filename = $ARGV[0] || Logger::die("usage: filename ats [year]");
my $ats  = $ARGV[1] || Logger::die("usage: filename ats [year]");
my $year = $ARGV[2];

Logger::die("Year format: YYYY_MM") if ($year !~ /^\d{4}\_\d{2}$/ && $year != '');

my $storage = CityBill::storage;
                                   
my $file = Source::autodetect(filename => $filename, year => $year);

$storage->store($file,$ats);

#$file->storeFile();
