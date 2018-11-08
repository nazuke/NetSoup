#!/usr/local/bin/perl -w

package NetSoup::Apache::Worms::Nimda;
use strict;
use Apache;
use Apache::URI;
use Apache::Constants;
use NetSoup::Protocol::Mail;
@NetSoup::Apache::Worms::Nimda::ISA = qw( NetSoup::Protocol::Mail );
1;


sub handler {
  my $r = shift;
  $r->content_type( 'text/plain' );
  $r->send_http_header();
  return( 401 );
}
