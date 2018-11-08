#!/usr/local/bin/perl -w

use strict;
use Getopt::Std;
use NetSoup::XHTML::MenuMaker::Drivers::NS4;
use NetSoup::Files::Load;

my %OPTIONS = ();
getopt( "chios",     \%OPTIONS ); # Options and arguments
getopts( "hjz", \%OPTIONS ); # Single character options
my $pathname   = $OPTIONS{i} || "MenuMaker.xml";
my $outfile    = $OPTIONS{o} || "MenuMaker_NS4.js";
my $stylesheet = "";
if( $OPTIONS{s} ) {
  $stylesheet = NetSoup::Files::Load->new()->immediate( Pathname => $OPTIONS{s} );
}
my $NS4 = NetSoup::XHTML::MenuMaker::Drivers::NS4->new( EmitJS     => 1,
                                                        CompressJS => $OPTIONS{z},
                                                        Stylesheet => $stylesheet,
                                                        Hilite     => $OPTIONS{h},
                                                        Normal     => $OPTIONS{c} );
$NS4->build( Pathname => $pathname, Target => $outfile );
exit(0);


__DATA__

  -i  XML Specification File

  -o  Output JavaScript File

  -s  CSS Stylesheet File
