package SoftX3000v5;
use base 'Source';
use strict;

sub readFile {
  my $self = shift();
  my $process = shift();
  until (eof($$self{filehandle})) {
    my $rec = $self->readRecord();
    $process->($rec);
    $self->{fileblocks}++;}}
#    foreach ($self->fields){
#      print " | " . $rec->($_)}
#    print "\n"}} 
    
#    print $rec->csn . " | " . $rec->length . " | " . $rec->net_type . " | " . $rec->bill_type . "\n";

sub readRecord{
  my $self = shift();
  my $rec = SoftX3000v5Record->new($$self{filehandle})}

#sub ftime {
#  my $self = shift;
#  my $ftime = $self->filebasename;
#  return $self->filetime if (!($ftime =~ /^(\d\d\d\d)(\d\d)(\d\d)\d+\.(bil|BIL)/));
#  join("-",$1,$2,$3) . " 00:00:00"}

sub tablename {
  "SX3000V5"}

sub fields{
  qw/caller peer calltime duration trunk_in trunk_out
  	csn net_type bill_type check_sum 
  	      end_time
  	      conversation_time
  	caller_dnset caller_address_nature
  	called_dnset called_address_nature
  	      centrex_group_number caller_ctx_number called_ctx_number
  	caller_did called_did caller_category 
  	      gsvn termcode/}

1;

#########################################################################
package SoftX3000v5Record;
use base 'CDR';
use fields qw/csn net_type bill_type check_sum
	    bf1 bf2
            YY MM DD hh mm ss
            eYY eMM eDD ehh emm ess
	        conversation_time 
	    caller_dnset caller_address_nature caller 
		called_dnset called_address_nature peer
       	    centrex_group_number caller_ctx_number called_ctx_number
       	    trunk_in trunk_out
       	caller_did called_did caller_category bf3
	    gsvn termcode
	        filler/;
use POSIX ('ceil');

sub new {
  my $self = shift();
  my $fh    = shift();

  my ($buf, $tmp);

  read $fh, $buf, 250;

  my $self = fields::new($self) unless ref $self;
  
  @$self{qw/csn net_type bill_type check_sum
	    bf1 bf2
            YY MM DD hh mm ss
            eYY eMM eDD ehh emm ess
	        conversation_time 
	    caller_dnset caller_address_nature caller 
		called_dnset called_address_nature peer
       	    centrex_group_number caller_ctx_number called_ctx_number
       	    trunk_in trunk_out
       	caller_did called_did caller_category bf3
	    gsvn termcode
	        filler/}=
        unpack 
           "VCCC
        CC
            CCCCCC
            CCCCCC
            V
        vCH[20]
        vCH[20]
            H[4]H[10]H[10]
            H[4]H[4]
        CCCC
	    CC
        A*", $buf;

  map {tr/f//d} @$self{'caller', 'peer'};

  $$self{caller} =~ s/^(\d{6})$/7232$1/ if ($$self{caller_dnset}==0);
  $$self{caller} =~ s/^(\d{6})$/7222$1/ if ($$self{caller_dnset}==1);

#  $$self{caller} =~ s/^3232(\d{6})$/$1/;
#  $$self{caller} =~ s/^32323232(\d{6})$/$1/;
#  $$self{caller} =~ s/^7232(\d{6})$/$1/;
#  $$self{caller} =~ s/^72327232(\d{6})$/$1/;

  return $self}

#partial_record_inicator valid_indicator clock_indicator free_indicator call_attempt_indicator complain_indicator cama_indicator is_credit_indicator cng charge_party_indicator end_time 

sub calltime {
  my $self = shift();
  sprintf "20%02u-%02u-%02u %02u:%02u:%02u", @$self{qw/YY MM DD hh mm ss/}}

sub end_time {
  my $self = shift();
  sprintf "20%02u-%02u-%02u %02u:%02u:%02u", @$self{qw/eYY eMM eDD ehh emm ess/}}

sub duration {
  my $self = shift();
  ceil($$self{conversation_time} / 100)}

1;