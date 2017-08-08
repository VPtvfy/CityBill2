package SQLCDRStorage;
use strict;
use DBI;
use Logger;
use Digest::MD5;

sub new {
  my $class       = shift;
  my $self        = {};
  bless $self, $class}

sub DESTROY {
  my $self = shift();
  if ($self->{dbh}){
    $self->{dbh}->rollback();
    $self->{dbh}->disconnect();}
  }


sub dbh {
  my $self = shift;
  return $self->{dbh} if ($self->{dbh});
  $self->{dbh} = DBI->connect($self->dsn, $self->user, $self->passwd) || Logger::die("Can't connect to SQL server " . $self->dsn) if (!$self->{dbh});
  $self->{dbh}->{HandleError} = sub { Logger::die($_[0]) };
  $self->{dbh}->{AutoCommit} = 0;
  $self->{dbh}->{PrintError} = 0;
  $self->{dbh}}

sub store {
  my $self = shift;
  my $source = shift;
  my $ats = shift;
  my $atsmodule = shift;
  my ($tmp, $lastid, $lastfname, $file);

  $tmp = $self->dbh->prepare("SELECT id,name FROM cb.files WHERE md5 = ? and filesize = ?");
  $tmp->execute($source->md5sum, $source->filesize);

  ($lastid,$lastfname) = $tmp->fetchrow_array;
  $tmp->finish();  
  if ($lastid){
      my $md5sum = $source->md5sum;
      Logger::write("file '" . $source->filebasename ."' already exists");
      $source->{error} = 9;
      
      my $sth = $self->dbh->prepare("INSERT INTO cb.files (name, filetime, ftime, filesize,ats,atsmodule,time,md5,status) VALUES (?, TO_DATE(?,'YYYY-MM-DD HH24:MI:SS'), TO_DATE(?,'YYYY-MM-DD HH24:MI:SS'), ?,?,?,CURRENT_DATE,?,?)");
      $sth->execute($source->filebasename, $source->filetime, $source->ftime, $source->filesize, $ats, $atsmodule, $md5sum, $source->error)}

  if ((!$lastid || $source->param eq 'force')){
    my $sth = $self->dbh->prepare("INSERT INTO cb.files (name, filetime, ftime, filesize,ats,atsmodule,time,md5,status) VALUES (?, TO_DATE(?,'YYYY-MM-DD HH24:MI:SS'), TO_DATE(?,'YYYY-MM-DD HH24:MI:SS'), ?,?,?,CURRENT_DATE,?,?)");
    $sth->execute($source->filebasename, $source->filetime, $source->ftime, $source->filesize, $ats, $atsmodule, $source->md5sum,$source->error);
    if (!$source->error){
      $file = $self->last_file_id;
      $sth = $self->dbh->prepare($self->queryText("call_" . $source->tablename,$source->fields));
      $source->readFile(sub {my $cdr = shift; $sth->execute($file, $self->row($source,$cdr))});
      my $sth = $self->dbh->prepare("UPDATE cb.files SET blocks = ?,records=?,storetab=? WHERE id = ?");
      $sth->execute($source->fileblocks, $source->filerecords, $source->tablename, $file)}
    Logger::write("file '$lastfname', id '$lastid' overwrited with '" . $source->filebasename . "', id '$file'") if (($source->param eq 'force') && ($lastid))}

  $self->dbh->commit()}

sub filesFromATS {
  my $self = shift;
  my $ats  = shift;
  my @oldfiles;

  my $dbh = $self->dbh;

  my $sth = $dbh->prepare("SELECT replace(name,'.gz','') as name FROM cb.files WHERE ats = ? OR ats = ?");
  $sth->execute($ats, ($ats . "b"));
  
  while (my $fname = $sth->fetchrow_array) {
    $fname =~ s/\.CA[LPD]//i;
    push @oldfiles,$fname};

  $sth->finish();
  @oldfiles}

sub listFiles {
  my $self= shift;
  my $month = shift;
  my $year = shift;
  my $atss = shift;
  my $dat = sprintf("%02d_%4d",$month,$year);

  my $dbh = $self->dbh;
  my $sql = "SELECT name,to_char(time,'DD.MM.YY HH24:MI') as utime,to_char(filetime,'DD.MM.YY HH24:MI') as filetime, ats||decode(atsmodule,'','','-'||atsmodule) ats,CASE WHEN filesize>1048576  THEN round(filesize/1048576,2)||' Mb' WHEN filesize>1024 THEN round(filesize/1024,2)||' Kb' ELSE filesize || ' b' END AS filesize,DECODE(status,0,'норм.',null,'норм.',9,'','повр.') || DECODE(blocks,null,'',' (' || blocks || DECODE(blocks,records,' записей',' блоков') || ')') || decode(status,9,' дубликат','') AS statstr,decode(status,9,0,status) as stat FROM cb.files WHERE ftime BETWEEN to_date('01_'||?,'DD_MM_YYYY') and to_date(to_char(last_day(to_date(?,'MM_YYYY')),'DD')||'_'||?,'DD_MM_YYYY') AND upper('$atss') like '%'||upper(nvl(SUBSTR(ats, 1 ,INSTR(ats, '-', 1, 1)-1),ats))||'%' ORDER BY ftime DESC"; 

  my $sth = $dbh->prepare($sql);
  $sth->execute($dat,$dat,$dat);

  my $result = $sth->fetchall_arrayref({});

  $sth->finish();
  $result}

sub stinfo {
  my $self= shift;
  my $atss = shift;

  my $dbh = $self->dbh;
  my $sql = "select stations.ats,nvl(cnt,0) as cnt from (select distinct upper(nvl(SUBSTR(ats, 1 ,INSTR(ats, '-', 1, 1)-1),ats)) as ats from cb.files where upper('$atss') like '%'||upper(nvl(SUBSTR(ats, 1 ,INSTR(ats, '-', 1, 1)-1),ats))||'%') stations left join (select upper(nvl(SUBSTR(ats, 1 ,INSTR(ats, '-', 1, 1)-1),ats)) as ats, count(id) as cnt from cb.files where time>to_date(to_char((sysdate),'DD.MM.YYYY')||' 00:00:00','DD.MM.YYYY HH24:MI:SS') group by nvl(SUBSTR(ats, 1 ,INSTR(ats, '-', 1, 1)-1),ats)) c ON stations.ats = c.ats ORDER BY stations.ats";

  my $sth = $dbh->prepare($sql);
  $sth->execute;

  my $result = $sth->fetchall_arrayref({});

  $sth->finish();
  $result}

sub filesbyday {
  my $self= shift;
  my $atss = shift;

  my $dbh = $self->dbh;
#  my $sql = "select count(*) as cnt from cfiles where ftime>sysdate-30 AND upper('$atss') like '%'||upper(nvl(SUBSTR(ats, 1 ,INSTR(ats, '-', 1, 1)-1),ats))||'%' group by to_char(ftime,'YYYYMMDD') order by to_char(ftime,'YYYYMMDD')";
  my $sql = "select nvl(cnt,0) from (select to_char(sysdate - rownum,'YYYYMMDD') dat from all_objects where rownum<=30 order by rownum desc) d left join (select to_char(ftime,'YYYYMMDD') dat,count(*) as cnt from cb.files where ftime>sysdate-32 AND upper('$atss') like '%'||upper(nvl(SUBSTR(ats, 1 ,INSTR(ats, '-', 1, 1)-1),ats))||'%' group by to_char(ftime,'YYYYMMDD')) f on d.dat = f.dat order by d.dat";

  my $sth = $dbh->prepare($sql);
  $sth->execute;

  my @result = map {$$_[0]} @{$sth->fetchall_arrayref()};
  #my @result = $sth->fetchall_arrayref();

  $sth->finish();
  @result}


sub queryCDR {
  my $self = shift;
  my $query_id  = shift;

#  $ENV{NLS_LANG}='AMERICAN_CIS.';

  my $dbh = $self->dbh;

  my $sth = $dbh->prepare("SELECT DISTINCT caller,peer,TO_CHAR(calltime, 'DD.MM.YYYY HH24:MI:SS') as calltime_str,duration,calltime,f.ats stname,trunk_in,trunk_out FROM cb.query_result qr, cb.files f WHERE qr.file_id=f.id and query_id=? ORDER BY calltime");
  $sth->execute($query_id);

  my $result = $sth->fetchall_arrayref({});

  $sth->finish();
  $result}

sub userrights {
  my $self = shift;
  my $user  = shift;
  my $dbh = $self->dbh;
  my $sth = $dbh->prepare("select acc,prefix,atslist from cb.cityusers where upper(login) = upper(?)");
#  Logger::die("select acc,prefix,atslist from cb.cityusers where upper(login) like upper('$user')");
  $sth->execute($user);
  
  my @result = $sth->fetchrow_array;
  $sth->finish();
  @result}

sub addQuery {
  my $self = shift;

  my $dbh = $self->dbh;

  my $sth = $dbh->prepare("INSERT INTO cb.query (phone_number,fromdate,todate,query_user,dest,atslist) VALUES (?,to_date(?,'DD.MM.YYYY'),to_date(?,'DD.MM.YYYY'),?,?,?)");
  $sth->execute(@_);

  $sth->finish;
  $dbh->commit;
  1}

sub QueryName {
  my $self = shift;
  my $query_id = shift;
  my $query = "SELECT phone_number, TO_CHAR(fromdate, 'DD,MM,YYYY') AS fromdate, TO_CHAR(todate, 'DD,MM,YYYY') AS todate FROM cb.query where id = ?";

  my $dbh = $self->dbh;

  my $sth = $dbh->prepare($query);
  $sth->execute($query_id);

  my ($phone, $fromdate, $todate) = $sth->fetchrow_array;
  $sth->finish();
  my $date = $fromdate == $todate ? $fromdate : "$fromdate-$todate";
  $phone . "_$date"}

sub AllStations {
  my $self = shift;
  
  my $dbh = $self->dbh;

  my $sth = $dbh->prepare("SELECT station FROM cb.stations") or Logger::die($dbh->errstr);
  $sth->execute or Logger::die($dbh->errstr);

  my @result = map {$$_[0]} @{$sth->fetchall_arrayref()};
  $sth->finish();
  join '|', @result}

sub StationObjects {
  my $self = shift;
  
  my $dbh = $self->dbh;

  my $sth = $dbh->prepare("SELECT * FROM cb.stations WHERE get_protocol is not null") or Logger::die($dbh->errstr);
  $sth->execute or Logger::die($dbh->errstr);

  my $result = $sth->fetchall_arrayref({});
  
  $sth->finish();
  $result}


sub atslist_s {
  my $self = shift;
  my $atslist = shift;
  
  my $dbh = $self->dbh;

  my $sth = $dbh->prepare("SELECT station||'^'||rus_station FROM cb.stations where upper(?) like upper('%'||station||'%')") or Logger::die($dbh->errstr);
  $sth->execute($atslist) or Logger::die($dbh->errstr);

  my @result = map {$$_[0]} @{$sth->fetchall_arrayref()};
  $sth->finish();
  join '|', @result}

sub listQueries {
  my $self = shift;
  my $login = shift;
  
  my $query = "SELECT id,TO_CHAR(query_date, 'DD.MM.YYYY HH24:MI:SS') as query_datef,phone_number,CONCAT(CONCAT(TO_CHAR(fromdate, 'DD.MM.YYYY'),' - '),TO_CHAR(todate, 'DD.MM.YYYY')) as query_period,query_user,DECODE(dest,1,'входящие',2,'исходящие',3,'вх./исх.','глюк') as dest,DECODE(processed,0,'не обработан',1,'обработан','удален') as status,DECODE(processed,1,1,0) as havelink,cb.StationNames(atslist) atslist FROM cb.query";
  $query .= " WHERE upper(query_user) = upper(?)" if ($login ne '');
  $query .= " ORDER BY query_date DESC";

  my $dbh = $self->dbh;

  my $sth = $dbh->prepare($query) or Logger::die($dbh->errstr);
  if ($login ne '') {
    $sth->execute($login) or Logger::die($dbh->errstr)}
  else {
    $sth->execute or Logger::die($dbh->errstr)}

  my $result = $sth->fetchall_arrayref({});

  $sth->finish();
  $result}

sub JobInfo {
  my $self = shift;

  my $dbh = $self->dbh;

  my %config = do "config.pl";
  
  my $sth = $dbh->prepare("select TO_CHAR(last_date, 'DD.MM.YYYY HH24:MI:SS') as last_date, TO_CHAR(next_date, 'DD.MM.YYYY HH24:MI:SS') as next_date from user_jobs where job = ?") or Logger::die($dbh->errstr);
  $sth->execute($config{'oracle_job_num'}) or Logger::die($dbh->errstr);

  my @result = $sth->fetchrow_array();

  $sth->finish();
  @result}

sub row {
  my $self = shift;
  my $source = shift;
  my $cdr = shift;
  my @values;
  foreach ($source->fields){
  	push(@values,$cdr->$_)}
  #{@values}}
  @values}
#  ($cdr->caller, $cdr->peer, $cdr->calltime, $cdr->duration, $cdr->trunk_in, $cdr->trunk_out)}

1;