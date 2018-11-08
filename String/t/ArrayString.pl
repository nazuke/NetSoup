#!/usr/local/bin/perl -w

use NetSoup::String::ArrayString;

my $data  = "abcdefghijklmnopqrstuvwxyz";
my @array = ();
tie @array, "NetSoup::String::ArrayString", Data => \$data;
for( my $i = 0 ; $i <= 25 ; $i++ ) {
  print( "ITEM\t" . $array[$i] . "\n" );
}
exit(0);
