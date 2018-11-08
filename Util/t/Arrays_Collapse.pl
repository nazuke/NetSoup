#!/usr/local/bin/perl -w
use NetSoup::Util::Arrays;
my @array = qw( one
                two
                three
                three
                four
                four
                four
                five
                six
                seven
                seven
                seven
                seven
                seven
                seven
                seven
                seven
                eight
                eight
                eight
                eight
                eight
                eight
                nine
                ten
                ten
                ten
                ten
                ten );
my $Arrays = NetSoup::Util::Arrays->new();
foreach my $i ( $Arrays->collapse( Array => \@array ) ) {
  print( "$i\n" );
}
exit(0);
