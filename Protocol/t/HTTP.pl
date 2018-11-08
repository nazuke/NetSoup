#!/usr/local/bin/perl -w
use NetSoup::Protocol::HTTP;
my $HTTP     = NetSoup::Protocol::HTTP->new( Debug => 1 );
my $Document = $HTTP->get( URL => shift || "http://localhost/" );
print( $Document->body() );
exit(0);
