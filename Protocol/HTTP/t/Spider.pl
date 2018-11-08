#!/usr/local/bin/perl -w

use NetSoup::Protocol::HTTP::Spider;

my $url    = shift;
my $Spider = NetSoup::Protocol::HTTP::Spider->new();
$Spider->spider( URL      => $url,
                 Depth    => 10,
                 Callback => sub {
                   my %args     = @_;
                   my $URL      = $args{URL};
                   my $Document = $args{Document};
                   print( "DOCUMENT\t$URL\n" );
                   return(1);
                 } );
exit(0);
