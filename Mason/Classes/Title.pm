#!/usr/local/bin/perl

package NetSoup::Mason::Classes::Title;
use strict;
use NetSoup::Files::Load;
@NetSoup::Mason::Classes::Title::ISA = qw();
my $LOAD = NetSoup::Files::Load->new();
1;


sub title {
  my $Title = shift;
  my $r     = shift;
  my $uri   = shift;
  if( defined $uri ) {
    $uri         .= "index" if( $uri =~ m:/$: );
    my $pathname  = $r->lookup_uri( $uri )->filename();
    my ( $title ) = ( $LOAD->immediate( Pathname => $pathname ) =~ m/<h1[^<>]*>([^<>]+)<\/h1>/gis );
    return( $title || undef );
  }
  return( undef );
}
