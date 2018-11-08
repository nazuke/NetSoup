#!/usr/local/bin/perl

package NetSoup::Apache::HelloWorld;
1;

sub handler {
  my $r = shift;
  $r->send_http_header( 'text/html' );
  $r->print( "<p>Hello, World!</p>" );
  return( OK );
}
