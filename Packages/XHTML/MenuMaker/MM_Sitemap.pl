#!/usr/local/bin/perl -w

use strict;
use NetSoup::XHTML::MenuMaker::Drivers::Sitemap;

my $Sitemap  = NetSoup::XHTML::MenuMaker::Drivers::Sitemap->new( WithSummary => 1 );
my $pathname = shift || "MenuMaker.xml";
my $outfile  = shift || "MenuMaker_Sitemap.html";
$Sitemap->build( Pathname => $pathname, Target => $outfile );
exit(0);
