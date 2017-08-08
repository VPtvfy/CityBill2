package Web;
use strict;
use base 'CGI::Application';
use HTML::Template;
#use CGI::Application;
use CGI::Application::Plugin::AutoRunmode;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Redirect;

use Excel::Template;
#use Data::Dumper;
#use Date::Manip;
use Date::Calc qw/Days_in_Month/;
use CityBill;

sub cgiapp_init {
  my $app = shift;

  $app->session_config(
          CGI_SESSION_OPTIONS => [ "driver:file", $app->query, {Directory=>'c:\temp'} ],
	  DEFAULT_EXPIRY      => '+1d',
          COOKIE_PARAMS       => { -path  => '/',
				   -expires => '0'},
          SEND_COOKIE         => 1);

  $app->header_props(-type=>'text/html;charset=windows-1251')}


sub setup {
  my $self = shift;
  $self->mode_param('rm')} 


sub cgiapp_prerun {
  my $self = shift;

  $self->prerun_mode("login_form") if (!$self->authorized);
  $self->prerun_mode("files") if ($self->files_only && $self->authorized);
  1}

sub errmsg {
  my $self = shift;
  $$self{errmsg}}

sub authorized {
  my $self = shift;
  my $q = $self->query;
  
  unless ($self->session->param('authorized')) {
    return 0 unless ($q->param('login'));
    $$self{errmsg} = $self->ldap_auth($q->param('login'),$q->param('passw'));
    return 0 if ($$self{errmsg} ne '1')}
  1}

sub files_only {
  my $self = shift;
  $self->session->param('access')==0 ? 1 : 0}

sub login_form : Runmode {
  my $self = shift;

  my $tmpl = $self->load_tmpl('templates/login_form.html');
  $tmpl->param(ERRMSG => $self->errmsg) if ($self->errmsg ne '');
  $tmpl->output}

sub query_form : StartRunmode{
  my $self = shift;

  my $tmpl = $self->load_tmpl('templates/query_form.html');
  my (undef,undef,undef,$cday,$cmon, $cyear,undef,undef,undef) = localtime ();
  $cyear+=1900;
  $cmon++;

  my $atslist = CityBill::storage()->atslist_s($self->session->param('ats'));
#  my $atslist = $self->session->param('ats');
#  $atslist = $self->session->param('domainadmin') ? 'AMTS|DAMA|ats42|ats47|ats62|ats217|ats22|ats25|ats26|ats271|ats52' : $atslist;

  my $fromdate = sprintf "01.%02d.%4d", $cmon, $cyear;
  my $todate = sprintf "%02d.%02d.%4d", $cday, $cmon, $cyear;

  $tmpl->param(FROMDATE => $fromdate, TODATE => $todate, ATSLIST => $atslist, ERRMSG => ($$self{errmsg} != 1 ? $$self{errmsg} : undef));
  
  $tmpl->output}

sub add_query : Runmode {
  my $self     = shift;
  my $q        = $self->query;
  my $number   = $q->param('phone');
  my $fromdate = $q->param('fromdate');
  my $todate   = $q->param('todate');
  #my $dest = ($q->param('chkin') && $q->param('chkout')) ? 'both' : ($q->param('chkin')) ? 'in' : 'out';
  my $dest = $q->param('chkin') + $q->param('chkout')*2;
  my $atslist = $q->param('atslist');
  
  $$self{errmsg} = CityBill::storage()->addQuery($number,$fromdate,$todate,$self->session->param('login'),$dest,$atslist);
  "<script language='javascript'>alert('Ваш запрос добавлен в очередь'); document.location.href='/?rm=queries';</script>"}

sub queries : Runmode {
  my $self = shift;
  my $tmpl = $self->load_tmpl('templates/queries.html');
  my $login = $self->session->param('login');
  my $acc = $self->session->param('access');
  
  my $qrs  = (CityBill::storage()->listQueries($acc == 9 ? '' : $login));#?
  my ($prevjob, $nextjob)  = (CityBill::storage()->JobInfo);

  $tmpl->param(QUERIES => $qrs, PREVJOB => $prevjob, NEXTJOB => $nextjob);

  $tmpl->output}

sub stinfo : Runmode {
  my $self = shift;
  my $tmpl = $self->load_tmpl('templates/stinfo.html');
  my $acc = $self->session->param('access');
  my $atslist = $self->session->param('ats');
  
  $tmpl->param(ST => (CityBill::storage()->stinfo($atslist)));

  $tmpl->output}
  
sub filesgraph : Runmode {
  use GD::Graph::area;
  use POSIX qw(ceil floor);
  my $self = shift;
  my $ats = $self->query->param('atsname');
  $ats = $self->session->param('ats') if (!$ats);
  my @data;
  my @data1;
  my @data2;

  my (undef,undef,undef,$ld) = localtime(time - 86400);

  if($ld<30){ 
    my (undef,undef,undef,$fd,$fm,$fy) = localtime(time - 2592000); 
    my $md = Days_in_Month($fy,$fm);
    for (my $i=$fd;$i<=$md;$i++){
  	  push @data1,$i};
  	for (my $i=1;$i<=$ld;$i++){
  	  push @data1,$i}}
#  elsif ($ld==30){
#  	@data1 = (1..30)}
#  else {
#  	@data1 = (2..31)}
  #@data1=($fd..$md,1..$ld);
  
  @data2=CityBill::storage()->filesbyday($ats);
  @data = ([@data1],[@data2]);

  my $mygraph = GD::Graph::area->new(390, 100);
  
  print "@data";
  $mygraph->set( dclrs => [ qw(green) ] );
  my $myimage = $mygraph->plot([@data]) or die $mygraph->error;

  print "Content-type: image/png\n\n";
  print $myimage->png;
}

sub files : Runmode {
  my $self = shift;
  my $tmpl = $self->load_tmpl('templates/files.html');

  my $q = $self->query;
  my (undef,undef,undef,$cday,$cmon, $cyear,undef,undef,undef) = localtime ();
  $cyear+=1900;
  $cmon++;

  my $month = $q->param('month') || $cmon;
  my $year  = $q->param('year') || $cyear;
  my $atslist = $self->session->param('ats');
  
  $tmpl->param(MENU => !$self->files_only,MONTH => $month,YEAR => $year,FLS => (CityBill::storage()->listFiles($month,$year,$atslist)));
#  $tmpl->param(MENU => !$self->files_only,FLS => (CityBill::storage()->listFiles($month,$year,$atslist)));
  $tmpl->output}

sub query_result : Runmode {
  my $self = shift;
  my $tmpl = Excel::Template->new(
				FILENAME    => 'templates/xlstmpl.xml',
				USE_UNICODE => 1
				);
  my $q = $self->query;
  $self->header_props(
      '-type'                  => 'application/x-xls',
      '-content-disposition' => "attachment; filename=" . CityBill::storage()->QueryName($q->param('query_id')) . ".xls",
    );
  my $cdrs = (CityBill::storage()->queryCDR($q->param('query_id')));

  $tmpl->param(CDR => $cdrs);

  binmode(STDOUT);
  
  $tmpl->output}

sub logout : Runmode {
  my $self = shift;
  $self->session->param('authorized',0);
  $self->redirect("/")
#  $self->login_form;
}

sub ldap_auth {
  use Net::LDAP;
  use Data::Dumper;
  use strict;

  my $self = shift;

  my $user = shift;
  my $pass = shift;
  
  my %config = do "config.pl";

  my $ok = 0;
  my $domainadmin;

  my $ldap = Net::LDAP->new("ldap://" . $config{'ldap_server'}, version => 3) or return "$@";
  my $mesg = $ldap->bind("$user\@" . $config{'ldap_server'}, password => $pass);

  $mesg->code && return "Неправильный логин или пароль";

  $mesg = $ldap->search(
	base => $config{'ldap_base'}, 
	filter => "userprincipalname=$user\@" .$config{'ldap_server'});

  $mesg->code && return $mesg->error;
  
  if ($mesg->count == 1) {
    $ok = grep /$config{'ldap_citybill_group'}/i, $mesg->entry(0)->get_value("memberOf");
    $domainadmin = grep /$config{'ldap_admin_group'}/i, $mesg->entry(0)->get_value("memberOf")}

  $ldap->unbind;
  if ($ok ne '') {
    $self->session->param('authorized',1);
    $self->session->param('login',$user);
    #$self->session->param('domainadmin',$domainadmin);
    my ($acc,$prefix,$ats) = (0,'','');
    ($acc,$prefix,$ats) = CityBill::storage()->userrights($user);
    #return "Access denied. Get off" if ($acc);
    $acc = 9 if ($acc == 0 && $domainadmin);
    $ats = CityBill::storage()->AllStations() if (!$ats && $acc == 9);
    #$ats='AMTS|DAMA|ATS42|ATS47|ATS62|ATS217|ATS22|ATS25|ATS26|ATS271|ATS52' if (!$ats);
    $self->session->param('prefix',$prefix);
    $self->session->param('ats',$ats);
    $self->session->param('access',$acc)}
  "$ok"}

1;