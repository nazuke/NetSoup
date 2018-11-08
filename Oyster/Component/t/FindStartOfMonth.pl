#!/usr/local/bin/perl -w

use NetSoup::Oyster::Component::Calendar;

my $Calendar = NetSoup::Oyster::Component::Calendar->new();
for( my $i = 1 ; $i <= 12 ; $i++ ) {
  print( ( $i + 1 ) . "\t" . localtime( $Calendar->findStartOfMonth( Index => $i ) ) . "\n" );
}
exit(0);
