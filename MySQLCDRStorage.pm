package MySQLCDRStorage;
use base 'SQLCDRStorage';

sub dsn {
  "DBI:mysql:database=citybill;host=localhost"}#10.174.1.142"}

sub user {
  "root"}

sub passwd { 
  "kewlrunner"}

sub queryText {
  "INSERT INTO `call` (file_id, caller, peer, calltime, duration, trunk_in, trunk_out) VALUES (?, ?, ?, ?, ?, ?, ?)"}

sub row {
  my $self = shift;
  my $cdr = shift;
  ($cdr->caller, $cdr->peer, $cdr->calltime, $cdr->duration, $cdr->trunk_in, $cdr->trunk_out)}

1;