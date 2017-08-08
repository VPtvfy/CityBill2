use CGI ':standard';
use GD::Graph::area;
use POSIX qw(ceil floor);

use strict;
my @data;
my @data1;
my @data2;
my $i;

# Задаем данные.
for ($i=0;$i<=400;$i++){
  push(@data2,int rand 100);
  push(@data1,$i);}
@data = ([@data1],[@data2]);

my $mygraph = GD::Graph::area->new(500, 300);

my $myimage = $mygraph->plot(\@data) or die $mygraph->error;

print "Content-type: image/png\n\n";
print $myimage->png;