package OracleCDRStorage;
use base 'SQLCDRStorage';

sub dsn {
  "DBI:Oracle:database=citybill;host=citybill20.ustk.east.telecom.kz;sid=citybill"}

sub user {
  "datafiller"}

sub passwd { 
  "lfnfabkkth"}

sub queryText {
  my $self  = shift;
  my $tablename = shift;
  my @fields = @_;
  my $field;
  my $val;
  foreach (@fields){
  	$field .= (", " . $_);
    $val .= ((($_ eq 'calltime') || $_ eq 'end_time') ? ", TO_DATE(?,'YYYY-MM-DD HH24:MI:SS')" : ", ?")}
  "INSERT INTO cb.$tablename (file_id$field) VALUES (?$val)"}

sub last_file_id {
  my $self = shift;
  my  $tmp = $self->dbh->prepare('select cb.files_sq.currval from dual');
  $tmp->execute;
  my($file) = $tmp->fetchrow_array;
  $file}

1;
