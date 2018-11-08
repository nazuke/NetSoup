#!/usr/local/bin/perl -w

use strict;
use NetSoup::XHTML::MenuMaker::Drivers::W3C;

my $pathname = shift || "MenuMaker.xml";
my $outfile  = shift || "MenuMaker_W3C.java";
my $W3C      = NetSoup::XHTML::MenuMaker::Drivers::W3C->new( EmitJS     => 1,
                                                             CompressJS => 0,
                                                             xMethod     => "click" );
$W3C->build( Pathname => $pathname, Target => $outfile );
exit(0);
