#!/usr/local/bin/perl -w

use NetSoup::Oyster::Component::Calendar;

my $Calendar = NetSoup::Oyster::Component::Calendar->new();
my $Month    = undef;
if( ( defined $ARGV[0] ) && ( int $ARGV[0] >= 1 ) ) {
  $Month = $Calendar->month( Index => $ARGV[0] );
} else {
  $Month = $Calendar->month( Time => time );
}
print( $Month->XML() . "\n" );
exit(0);
