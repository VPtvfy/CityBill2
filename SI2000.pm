package SI2000;
use base 'Source';
use strict;

sub readFile {
  my $self = shift();
  my $process = shift();
  until (eof($$self{filehandle})) {
    my $rec = $self->readRecord();
    if ($rec->rectype==200){
      $process->($rec);
      $self->{fileblocks}++;}}}
#    foreach ($self->fields){
#      print " | " . $rec->($_)}
#    print "\n"}} 
    
#    print $rec->csn . " | " . $rec->length . " | " . $rec->net_type . " | " . $rec->bill_type . "\n";

sub readRecord{
  my $self = shift();
  my $rec = SI2000Record->new($$self{filehandle})}

#sub ftime {
#  my $self = shift;
#  my $ftime = $self->filebasename;
#  return $self->filetime if (!($ftime =~ /^(\d\d\d\d)(\d\d)(\d\d)\d+\.(bil|BIL)/));
#  join("-",$1,$2,$3) . " 00:00:00"}

sub tablename {
  "SI2000"}

sub fields{
  qw/csn recseq charge
		caller peer connected dialed
			calltime end_time
		pulse duration
			suppservice
		callerdn calleddn
			trunk_in trunk_out/}

1;

#########################################################################
package SI2000Record;
use base 'CDR';
use fields qw/rectype csn recseq charge
		caller peer connected dialed
			calltime end_time
		pulse duration duration1 duration2
			suppservice
		callerdn calleddn
			trunk_in trunk_out
			/;
use POSIX ('ceil');
use Time::Local;

sub new {
  my $self = shift();
  my $fh    = shift();

  my $self = fields::new($self) unless ref $self;

  my ($buf, $tmp);

  read $fh, $buf, 1;
  
  my $record_type = unpack( 'C', $buf );
  $$self{rectype}=$record_type;
  
  if ($record_type == 200){#detailed record
	read $fh, $buf, 15;
	my ($record_len,$b0,$b1,$b2,$b3,$b4);
	($record_len,$$self{csn},$b0,$b1,$b2,$b3,$b4) = unpack( 'nA[8]CCCCC',  $buf );
	$$self{'recseq'}=($b3 & 0b11110000) >> 4;
	$$self{'charge'}=($b3 & 0b1111);
	my $caller_len=(($b4 & 0b11100000) >>5)+($b4 & 0b00011111);
	read $fh,$buf,ceil($caller_len/2);
	($$self{caller})=unpack("H[$caller_len]",$buf);
	my $vlen=($record_len - 16 - ceil($caller_len/2));
	read $fh, $buf, $vlen;
    for( my $pos = 0; $pos < $vlen; ){
      my ($id) = unpack( 'C', substr( $buf, $pos, 1 ) );
	  if($id == 100){		# peer
		my ($num_len) = unpack( 'C', substr( $buf, ++$pos, 1 ) );
		$$self{peer} = unpack("H[$num_len]",substr($buf, ++$pos, ceil($num_len/2)));
		$pos += ceil($num_len/2);}
	  elsif( $id == 101 ){ #connected
	    ++$pos;
		my ($num_len) = unpack( 'C', substr( $buf, ++$pos, 1 ) );
		$$self{connected} = unpack("H[$num_len]",substr($buf, ++$pos, ceil($num_len/2)));
		$pos += ceil($num_len/2);}
	  elsif( $id == 102 ){ #calltime
		my @datetime = unpack('CCCCCC',substr( $buf, ++$pos, 6 ));
		$$self{calltime} = sprintf( '20%02d-%02d-%02d %02d:%02d:%02d', @datetime);
		$pos += 8;}
	  elsif( $id == 103 ){ #end_time
		my @datetime = unpack('CCCCCC',substr( $buf, ++$pos, 6 ));
		$$self{end_time} = sprintf( '20%02d-%02d-%02d %02d:%02d:%02d', @datetime);
		$pos += 8;}
	  elsif( $id == 104 ){ #pulse
		my @count = unpack( 'CS', substr( $buf, $pos + 1, 3 ) );
		$$self{pulse} = ($count[0] << 16) | $count[1];
		$pos += 4;}
 	  elsif( $id == 105 ){ #bearer
# 		my @service = unpack( 'CC', substr( $buf, $pos + 1, 2 ) );
# 		my $service_data = $service[0];
# 		my $service_phone = $service[1];
		$pos+=3;}
 	  elsif( $id == 106 ){ #supplemetary service
 		$$self{suppservice}=unpack('C',substr($buf,++$pos,1));
 		$pos++;}
 		# dop service u visivaemogo
 	  elsif( $id == 107 ){ #called supplementary service
		$pos += 2;}
	  elsif( $id == 108 ){ #govno
 			$pos += 3;}
 	  elsif( $id == 109 ){ #dialed
		my ($num_len) = unpack( 'C', substr( $buf, ++$pos, 1 ) );
		$$self{dialed} = unpack("H[$num_len]",substr($buf, ++$pos, ceil($num_len/2)));
		$pos += ceil($num_len/2);}
 	  elsif( $id == 110 ){ #caller dn
 		$$self{callerdn} = unpack( 'C', substr( $buf, ++$pos, 1 ) );
 		$pos++;}
	  elsif( $id == 111 ){ #called dn
 		$$self{calleddn} = unpack( 'C', substr( $buf, ++$pos, 1 ) );
 		$pos++;}
 	  elsif( $id == 112 ){ #reject reason
 		$pos += 2;}
 	  elsif( $id == 113 ){ #trunk_in
 		$$self{trunk_in} = unpack( 'H[4]', substr( $buf, ++$pos, 2 ) );
 		$pos += 8;}
 		# ishod tract
 	  elsif( $id == 114 ){ #trunk_out
 		$$self{trunk_out} = unpack( 'H[4]', substr( $buf, ++$pos, 2 ) );
 		$pos += 8;}
 	  elsif( $id == 115 ){ #duration
 		$$self{duration1} = unpack( 'N', substr( $buf, $pos + 1, 4 ) );
		$pos += 5;}
	  elsif( $id == 116 ){ #checksum
		$pos += 4;}
 	  elsif( $id == 117 ){ #business,centrex group
 		$pos += 10;}
 		# cod dostupa k seti
 	  elsif( $id == 118 ){ #CAC
 		my @len = unpack( 'C', substr( $buf, $pos + 1, 1 ) );
		$pos += $len[0];}
	  elsif( $id == 119 ){ #original calling party number	
		my @len = unpack( 'C', substr( $buf, $pos + 1, 1 ) );
		$pos += $len[0];}
	  elsif( $id == 120 ){ #govno 2
		$pos += 15;}
	  elsif( $id == 121 ){# disconnect cause 
		$pos += 5;}
	  elsif( $id == 122 ){# Charge Band Number
		$pos += 5;}
	  elsif( $id == 123 ){# Common Call Id
		$pos += 6;}
	  elsif( $id == 124 ){# Durations before Answer
		$pos += 10;}
	  elsif( $id == 125 )	{# VoIP Info
		$pos += 5;}
	  elsif( $id == 126 ){# Amount of Transferred Data			
		$pos += 13;}
	  elsif( $id == 127 ){# IP Addresses
 		my @len = unpack( 'C', substr( $buf, $pos + 1, 1 ) );
		$pos += $len[0];}
	  elsif( $id == 128 ){# VoIP Info
		$pos += 13;}
	  elsif( $id == 129 ){# Amount of Transferred Data
		$pos += 25;}
	  else{
		die "No processing code $id\n";}
    }
    if ($$self{calltime} && $$self{end_time}){
      $$self{calltime}=~ /(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/;
      my $time1=timelocal($6,$5,$4,$3,($2-1),($1-1900));
      $$self{end_time}=~ /(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/;
      my $time2=timelocal($6,$5,$4,$3,($2-1),($1-1900));
      $$self{duration2}=$time2-$time1;
    }
  }
  elsif($record_type == 210){# date time change record
    read $fh, $buf, 15;}
  elsif($record_type == 211){# lost records record	
    read $fh, $buf, 18;} 
  elsif($record_type == 212){# reboot record
    read $fh, $buf, 11;}
  else{
    die "Record parse error. unknown recordtype=".$record_type."\n";}

  return $self}

sub duration {
  my $self = shift();
  if ($$self{duration2}){
  	$$self{duration2};
  }else{
  	$$self{duration1};
  }
}

1;