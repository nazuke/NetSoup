#!/usr/local/bin/perl -w

use strict;
use NetSoup::XHTML::MenuMaker::Drivers::Hier;

my $Hier     = NetSoup::XHTML::MenuMaker::Drivers::Hier->new();
my $pathname = shift || "MenuMaker.xml";
my $outfile  = shift || "MenuMaker_W3C.html";
$Hier->build( Pathname => $pathname, Target => $outfile );
exit(0);
