package Logger;
use Net::SMTP;
use strict;
sub write {
  my $line = shift();
  my $logfile;
  my ($sec,$min,$hour,$day,$mon, $year,undef,undef,undef) = localtime ();
  $year+=1900;
  $mon++;
  open $logfile, ">>citybill.log";
  printf $logfile "%02d.%02d.%d %02d:%02d:%02d --- %s\n",$day,$mon,$year,$hour,$min,$sec,$line;
  printf "%02d.%02d.%d %02d:%02d:%02d --- %s\n",$day,$mon,$year,$hour,$min,$sec,$line;
  close $logfile;}

sub postletter {
  my $errstr = shift();
  my $smtp;
  my @mails = ('Evgeny_Karachkovsky@domino.east.telecom.kz');

  $smtp = Net::SMTP->new('odt.east.telecom.kz');
  $smtp->mail('ekar@odt.east.telecom.kz');
  $smtp->to(@mails);
  	 
  $smtp->data();
  $smtp->datasend("From: ekar\n");
  $smtp->datasend("To: ".join(",",@mails)."\n");
  $smtp->datasend("Subject: error while executing script on citybill\n");
  $smtp->datasend("\n");

  $smtp->datasend($errstr);
  $smtp->dataend();
  	 
  $smtp->quit}

sub die {
  my $errstr = shift();
  my $errnum = shift();
  my $smtp;
  print "$errstr\n";
  Logger::write($errstr);
  Logger::postletter
#  die($errnum);}
  exit}
1;
