#!/usr/local/bin/perl -w

use NetSoup::Protocol;

my $Protocol = NetSoup::Protocol->new();
my $quit     = 0;
my $data     = "";
$Protocol->server( Port => 8080 );
$Protocol->loop( Fork     => 0,
                 Quit     => \$quit,
                 Callback => sub {
                   $Protocol->get( Data => \$data );
                   print( $data );
                 } );
exit(0);
