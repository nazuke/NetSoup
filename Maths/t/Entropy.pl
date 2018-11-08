#!/usr/local/bin/perl -w

use NetSoup::Maths::Entropy;

my $Entropy = NetSoup::Maths::Entropy->new();

for( my $i = 1 ; $i <= 10 ; $i++ ) {
  print( $Entropy->random( Max => 100 ) . "\n" );
}

exit(0);
