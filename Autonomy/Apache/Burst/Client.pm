#!/usr/local/bin/perl -w

package NetSoup::Autonomy::Apache::Burst::Client;
use Apache;
use Apache::Constants;
use Apache::URI;
@NetSoup::Autonomy::Apache::Burst::Client::ISA = qw();
1;

sub handler {
  my $r = shift;
  $r->content_type( "text/html" );
  $r->send_http_header();
  
  return( OK );
}
