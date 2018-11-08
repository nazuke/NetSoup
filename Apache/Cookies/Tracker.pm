#!/usr/local/bin/perl -w

package NetSoup::Apache::Cookies::Tracker;
use strict;
use Apache;
use Apache::Constants qw( :http :response );
use NetSoup::Apache::Cookies;
use NetSoup::Encoding::Hex;
use constant HEX => NetSoup::Encoding::Hex->new();
@NetSoup::Apache::Cookies::Tracker::ISA = qw();
1;


sub fixup {
  # This method sets a cookie.
  my $r       = shift;
  my $Cookies = NetSoup::Apache::Cookies->new( Request => $r );
  my $key     = $r->dir_config( "COOKIE_KEY" );
  my $value   = $Cookies->getCookie( Key => $key );
  if( ! defined $value ) {
    $r->header_out( 'Set-Cookie' => $Cookies->setCookie( Key     => $key,
                                                         Value   => $Cookies->randCookie(),
                                                         Expires => ( 60 * 60 * 24 * 365 ),
                                                         Domain  => $r->hostname(),
                                                         Path    => "/" ) );
  }
  return( OK );
}


sub img {
  # This method returns an invisible placeholder GIF.
  # Attach the fixup handler to this image to set a cookie.
  my $r = shift;
  $r->send_http_header( 'image/gif' );
  $r->print( HEX->hex2bin( Data => join( "", qw( 4749 4638 3961 0800 0800 9100 0000 0000
                                                 FFFF FFFF FFFF 0000 0021 F904 0100 0002
                                                 002C 0000 0000 0800 0800 0002 0794 8FA9
                                                 CBED 5D00 003B ) ) ) );
  return( OK );
}
