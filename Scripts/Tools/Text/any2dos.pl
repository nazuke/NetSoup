#!/usr/local/bin/perl -w


use NetSoup::Files::Convert::Any2Dos;


my $Any2Dos = NetSoup::Files::Convert::Any2Dos->new( Verbose => 1 );
foreach my $pathname ( @ARGV ) {
  $Any2Dos->convert( Pathname => $pathname );
}
exit(0);
