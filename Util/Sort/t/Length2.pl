#!/usr/local/bin/perl
use NetSoup::Util::Sort::Length;
my @array = ();
while ( <DATA> ) {
  chop;
  push( @array, $_ ) if( $_ );
}
my $object = NetSoup::Util::Sort::Length->new();
foreach ( @array ) { print "$_\n" }
$object->sort2( Array => \@array );
print "\n" x 4;
foreach ( @array ) { print "$_\n" }
exit(0);


__DATA__
123890
12390
123456790
12367890
1234567890
123678
3467890
123
12567890
12345
