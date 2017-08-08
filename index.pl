use Web;

#$ENV{CGI_APP_DEBUG}=1;

#@ENV{NLS_LANG,ORA_NLS33,ORACLE_HOME} = ('AMERICAN_CIS.CL8MSWIN1251','d:\oracle\ora92\ocommon\nls\admin\data','d:\oracle\ora92');
$ENV{NLS_LANG} = 'AMERICAN_CIS.CL8MSWIN1251';

my $app = Web->new();

$app->run();
