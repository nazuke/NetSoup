#!/usr/local/bin/perl -w

package NetSoup::Apache::Images::MenuMaker::Icon;
use strict;
use Apache::Constants;
use Apache::URI;
use NetSoup::Encoding::Hex;
use constant HEX => NetSoup::Encoding::Hex->new();
1;


sub handler {
  my $r = shift;
  $r->content_type( 'image/gif' );
  $r->send_http_header();
  $r->print( HEX->hex2bin( Data => "4749463839610800070080FF00C0C0C0FFFFFF21F90401000000002C000000000800070040020A848F1719DD09A3711214003BA3711214003B" ) );
  return( OK );
}
