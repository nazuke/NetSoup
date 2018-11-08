#!/usr/local/bin/perl -w

use NetSoup::Protocol;
use NetSoup::Protocol::UDP;

my $UDP = NetSoup::Protocol::UDP->new();
for(;;) {
  my $message = $UDP->receive( IP      => NetSoup::Protocol->new()->_address( Address => "255.255.255.255" ),
                               Port    => 8888 );
  print( $message );
  sleep(1);
}
exit(0);
