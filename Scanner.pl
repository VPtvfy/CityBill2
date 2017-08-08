use Logger;
use ScanFTP;
use ScanShare;
use ScanLocal;
use Citybill;
use Data::Dumper;
use Fcntl ":flock";

$lockfilename="citybill.pid";

unless (open(LOCKFILE, ">$lockfilename")) {
  Logger::die("Program is already running. Now quit");
}
unless (flock(LOCKFILE, LOCK_EX|LOCK_NB)) {
  Logger::die("Program is already running. Now quit");
}

my $stations = CityBill::storage()->StationObjects();

foreach my $station (@$stations) {
  eval{ ("Scan" . $$station{GET_PROTOCOL})->new(%$station)->scan };
  if ($@) {
    Logger::write("ERROR: $@")}}


close(LOCKFILE);
unlink($lockfilename);
