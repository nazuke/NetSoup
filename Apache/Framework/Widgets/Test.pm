#!/usr/local/bin/perl

package NetSoup::Apache::Framework::Widgets::Test;
use strict;
use Apache;
use Apache::Constants qw( :http :response );
use NetSoup::Apache;
@NetSoup::Apache::Framework::Widgets::Test::ISA = qw( NetSoup::Apache );
1;


sub widget {
  my $Test   = shift;
  my $r      = shift;
  my $Node   = shift;
  my $string = "<p>Test Widget Result</p>";
  for( my $i = 1 ; $i <= 10 ; $i++ ) {
    $string .= "<p>i = $i</p>";
  }
  return( $string );
}
