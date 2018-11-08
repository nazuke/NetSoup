#!/usr/local/bin/perl -w


use NetSoup::Protocol::BatchUp;


my $chunk   = join( "", <DATA> );
my $BatchUp = NetSoup::Protocol::BatchUp->new( Hostname => "localhost",
                                               Port     => 8080,
                                               QLength  => 50,
                                               Postfix  => "Postfix\n" );
for( my $i = 1 ; $i <= 10 ; $i++ ) {
  for( my $j = 1 ; $j <= 50 ; $j++ ) {
    $BatchUp->add( Data => "$j $chunk" );
  }
}
exit(0)
  

__DATA__
The quick brown fox jumps over the lazy dog.
