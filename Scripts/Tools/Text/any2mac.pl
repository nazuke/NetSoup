#!/usr/local/bin/perl -w


use NetSoup::Files::Convert::Any2Mac;


my $Any2Mac = NetSoup::Files::Convert::Any2Mac->new( Verbose => 1 );
foreach my $pathname ( @ARGV ) {
  $Any2Mac->convert( Pathname => $pathname );
}
exit(0);
