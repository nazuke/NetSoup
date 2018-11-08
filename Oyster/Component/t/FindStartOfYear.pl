#!/usr/local/bin/perl -w

use NetSoup::Oyster::Component::Calendar;

my $Calendar = NetSoup::Oyster::Component::Calendar->new();
my $now      = time;
print( localtime($now) . "\t$now\n" );
print( localtime( $Calendar->findStartOfYear( Time => $now ) ) .
       "\t" . $Calendar->findStartOfYear( Time => $now ) . "\n" );
exit(0);
