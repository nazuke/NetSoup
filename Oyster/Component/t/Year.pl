#!/usr/local/bin/perl -w

use NetSoup::Oyster::Component::Calendar;

my $Calendar = NetSoup::Oyster::Component::Calendar->new();
my $Year     = $Calendar->year( Time => time );
print( $Year->XML() . "\n" );
exit(0);
