#!/usr/local/bin/perl -w

package NetSoup::Apache::System::Load;
use strict;
use Apache;
use Apache::Constants qw( :common :http :response );
use NetSoup::Core;
use NetSoup::Files::Load;
use constant LOAD => NetSoup::Files::Load->new();
@NetSoup::Apache::System::Load::ISA = qw( NetSoup::Core );
1;


sub handler {
  my $r       = shift;
  my $loadavg = LOAD->immediate( Pathname => "/proc/loadavg" );  
  $r->send_http_header( "text/plain" );
  $r->print( $loadavg );  
  return( OK );
}
