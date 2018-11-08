#!/usr/local/bin/perl -w

use strict;
use Getopt::Std;
use NetSoup::XHTML::MenuMaker::Drivers::Cascade;
use NetSoup::Files::Load;

my %OPTIONS = ();
getopt( "chios", \%OPTIONS ); # Options and arguments
getopts( "hjz",  \%OPTIONS ); # Single character options
my $pathname   = $OPTIONS{i} || "MenuMaker.xml";
my $outfile    = $OPTIONS{o} || "MenuMaker_Cascade.js";
my $stylesheet = "";
if( $OPTIONS{s} ) {
  $stylesheet = NetSoup::Files::Load->new()->immediate( Pathname => $OPTIONS{s} );
}
my $Cascade = NetSoup::XHTML::MenuMaker::Drivers::Cascade->new( EmitJS     => 1,
                                                                CompressJS => $OPTIONS{z},
                                                                Stylesheet => $stylesheet,
                                                                Hilite     => $OPTIONS{h},
                                                                Normal     => $OPTIONS{c} );
$Cascade->build( Pathname => $pathname, Target => $outfile );
exit(0);


__DATA__

  -i  XML Specification File

  -o  Output JavaScript File

  -s  CSS Stylesheet File
