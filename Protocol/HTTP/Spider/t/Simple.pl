#!/usr/local/bin/perl -w

use NetSoup::Protocol::HTTP::Spider::Simple;

my $url    = shift;
my $Spider = NetSoup::Protocol::HTTP::Spider::Simple->new();
$Spider->spider( URL      => $url,
                 Depth    => 20,
                 Callback => sub {
                   my %args     = @_;
                   my $URL      = $args{URL};
                   my $Document = $args{Document};
                   return(1);
                 } );
exit(0);
