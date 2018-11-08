#!/usr/local/bin/perl -w
use NetSoup::Maths::Entropy;
use NetSoup::Maths::Suffix;
my $Entropy = NetSoup::Maths::Entropy->new();
my $Suffix  = NetSoup::Maths::Suffix->new();
for( my $i = 1 ; $i <= 100 ; $i++ ) {
  print( $Suffix->append( $Entropy->random( Max => 200 ) ) . "\n" );
}
exit(0);
