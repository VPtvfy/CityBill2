package CDR;
use overload ('""' => 'asString');

sub asString {
  my $self = shift;
  my $res = "";
  my $res = sprintf "%10s %15s %15s %10s %5s %5s", 
	$self->caller, 
	$self->peer, 
	$self->calltime, 
	$self->duration,
	$self->trunk_in,
	$self->trunk_out;
	
  $res}


sub AUTOLOAD {
  our $AUTOLOAD;
  my $self = shift();
  my $method = $AUTOLOAD;
  $method =~ s/.*:://;
#  print "AUTOLOAD: $AUTOLOAD\n";
  return $$self{$method} if exists $$self{$method};
  return undef();}


sub caller {
  my $self = shift;
  my $caller = $$self{caller};

  $caller =~ s/^3232(\d{6})$/7232$1/;
  $caller =~ s/^03232(\d{6})$/7232$1/;
  $caller =~ s/^32(\d{6})$/7232$1/;
  $caller =~ s/^(\d{6})$/7232$1/;
  $caller =~ s/^07232(\d{6})$/7232$1/;
  $caller}

1;
