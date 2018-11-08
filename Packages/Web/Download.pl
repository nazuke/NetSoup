#!/usr/local/bin/perl -w

use NetSoup::Protocol::HTTP::Spider::Download;
use NetSoup::URL::Parse;

my $URL      = shift;
my $Download = NetSoup::Protocol::HTTP::Spider::Download->new();
my $URLParse = NetSoup::URL::Parse->new();
my $folder   = $URLParse->hostname( $URL ) . "/";
mkdir( $folder, 0755 );
$Download->download( URL    => $URL,
                     Prefix => $folder );
exit(0);
