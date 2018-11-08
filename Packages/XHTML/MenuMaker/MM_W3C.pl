#!/usr/local/bin/perl -w

use strict;
use NetSoup::XHTML::MenuMaker::Drivers::W3C;

my $W3C      = NetSoup::XHTML::MenuMaker::Drivers::W3C->new();
my $pathname = shift || "MenuMaker.xml";
my $outfile  = shift || "MenuMaker_W3C.html";
$W3C->build( Pathname => $pathname, Target => $outfile );
exit(0);
