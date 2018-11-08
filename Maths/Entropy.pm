#!/usr/local/bin/perl -w

package NetSoup::Maths::Entropy;
use strict;
use NetSoup::Core;
@NetSoup::Maths::Entropy::ISA = qw( NetSoup::Core );
1;

sub BEGIN {
  if( open( RANDOM, "/dev/random" ) ) {
    my $bytes = "";
    sysread( RANDOM, $bytes, 4 );
    close( RANDOM );
    srand( time + unpack( "I", $bytes ) );
  } else {
    srand( time * 3.1415927 );
  }
}

sub initialise {
  my $Entropy = shift;
  my %args    = @_;
  return( $Entropy );
}

sub random {
  my $Entropy = shift;
  my %args    = @_;
  my $max     = $args{Max};
  return( int rand( $max ) );
}
