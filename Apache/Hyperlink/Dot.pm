#!/usr/local/bin/perl -w

package NetSoup::Apache::Hyperlink::Dot;
use strict;
use Apache::Constants;
use NetSoup::Encoding::Hex;
use constant HEX => NetSoup::Encoding::Hex->new();
@NetSoup::Apache::Hyperlink::Dot::ISA    = qw();
1;


sub handler {
  # This method returns a dot image to be placed next to the automatic links.
  my $r = shift;
  $r->content_type( "image/gif" );
  $r->send_http_header();
  my $img = HEX->hex2bin( Data => join( "", qw( 4749
                                                4638
                                                3961
                                                0800
                                                0800
                                                A100
                                                0032
                                                CD32
                                                F5F5
                                                DCFF
                                                0000
                                                FFFF
                                                FF21
                                                FE15
                                                4372
                                                6561
                                                7465
                                                6420
                                                7769
                                                7468
                                                2054
                                                6865
                                                2047
                                                494D
                                                5000
                                                21F9
                                                0401
                                                0000
                                                0000
                                                2C00
                                                0000
                                                0008
                                                0008
                                                0000
                                                020F
                                                848F
                                                1092
                                                BBE7
                                                8434
                                                6249
                                                466F
                                                9A29
                                                1500
                                                3B00 ) ) );
  $r->print( $img );
  return( OK );
}
