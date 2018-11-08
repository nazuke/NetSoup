#!/usr/local/bin/perl -w

use NetSoup::Files::Load;

print( NetSoup::Files::Load->new()->immediate( Pathname => "testfile.txt" ) );
exit(0);
