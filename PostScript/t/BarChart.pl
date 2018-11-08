#!/usr/local/bin/perl -w

use NetSoup::PostScript::BarChart;
use NetSoup::Maths::Entropy;

my $BarChart = NetSoup::PostScript::BarChart->new();
my $Entropy  = NetSoup::Maths::Entropy->new();
my %hash     = ();
my $max      = $Entropy->random( Max => 10 );
for( my $i = 1 ; $i <= $max ; $i++ ) {
  $hash{$i} = $Entropy->random( Max => 100 );
}
my $PNG = $BarChart->barchart( Values => \%hash );
print( STDOUT $PNG );
exit(0);
