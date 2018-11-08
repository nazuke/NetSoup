#!/usr/local/bin/perl -w

use NetSoup::Protocol;
use NetSoup::Protocol::UDP;

my $UDP = NetSoup::Protocol::UDP->new();
$| = 1;
for(;;) {
  if( defined $UDP->broadcast( IP      => NetSoup::Protocol->new()->_address( Address => "127.0.0.1" ),
                               Port    => 8888,
                               Message => "Hello" ) ) {
    print( "." );
  } else {
    print( "\nError\n" );
  }
  sleep(2);
}
exit(0);
