#!/usr/local/bin/perl -w

package NetSoup::Apache::Worms::CodeRed;
use strict;
use Apache::URI;
use NetSoup::Protocol::Mail;
@NetSoup::Apache::Worms::CodeRed::ISA = qw( NetSoup::Protocol::Mail );
1;


sub handler {
  my $r = shift;
  $r->content_type( 'text/plain' );
  $r->send_http_header();
  print( "CodeRed\n" );
  return( "OK" );  
}
