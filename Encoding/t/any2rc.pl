#!/usr/local/bin/perl -w


use strict;
use NetSoup::Encoding::Win32RC;
use NetSoup::Files::Load;
use NetSoup::Files::Save;
use Getopt::Std;


my %OPTIONS      = ();
getopt( "in", \%OPTIONS );                              # ID and Name
my $Win32RC      = NetSoup::Encoding::Win32RC->new();   # Get new RC encoder
my $Load         = NetSoup::Files::Load->new();
my $Save         = NetSoup::Files::Save->new();
my $pathname     = $ARGV[0];
my ( $outpath )  = ( $pathname =~ m/^(.+)\.[^\.]+$/ );  # Construct RC pathname
my $data         = "";
$Load->load( Pathname => $pathname,
             Data     => \$data,
             Binary   => 1 );
my $output = $Win32RC->bin2hex( ID   => $OPTIONS{i},
                                Name => $OPTIONS{n},
                                Data => \$data);
print( "$output\n" );
$Save->save( Pathname => "$pathname.rc",
             Data     => \$output );                    # Save file
exit(0);
