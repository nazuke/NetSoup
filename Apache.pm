#!/usr/local/bin/perl -w

package NetSoup::Apache;
use strict;
use Apache;
use Apache::Constants qw( :common :http :response );
use NetSoup::Core;
@NetSoup::Apache::ISA = qw( NetSoup::Core );
1;


sub backref {
  # This method searches back through the Request
  # Object chain to find the top-most URI.
  my $Apache = shift;
  my $r      = shift;
  my $uri    = "";
  my $back_r = $r;
 BACK_REF: while( defined $back_r ) {
    $uri    = $back_r->uri();
    $back_r = $back_r->main() || undef;
  }
  $uri =~ s/^(.+)\..?html(.*)$/$1$2/;
  $uri =~ s:/index$:/:;
  return( $uri );
}


sub nolog {
  # Useful for null logging of images etc.
  my $r = shift;
  return( OK );
}
