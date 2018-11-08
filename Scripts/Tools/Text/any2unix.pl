#!/usr/local/bin/perl -w


use NetSoup::Files::Convert;


my $Convert = NetSoup::Files::Convert->new( Verbose => 1 );
foreach my $pathname ( @ARGV ) {
  $Convert->convert( Pathname => $pathname );
}
exit(0);
