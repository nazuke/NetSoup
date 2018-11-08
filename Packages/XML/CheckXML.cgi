#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::CheckXML.cgi v00.00.01a 12042000
#
#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This Perl 5.0 script applies the NetSoup XML Parser to one
#                or more files, and displays any errors encountered.


use strict;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::Protocol::HTTP;
use NetSoup::HTML::Parser;
use NetSoup::XML::Parser;
use NetSoup::XML::Util;
use Getopt::Std;


my $ACCEPTS  = NetSoup::XML::Util->accepts();
my %OPTIONS  = ();
my %ENTITIES = ();
my @EMPTY    = ();
getopt(  "em",      \%OPTIONS );
getopts( "dhHlSsTv", \%OPTIONS );
if( $OPTIONS{h} ) {
	print( join( "", <DATA> ) );
	exit(0);
}
if( $OPTIONS{e} ) {
	if( open( FILE, $OPTIONS{e} ) ) {
	ENT: while( <FILE> ) {
			chomp;
			$ENTITIES{$_} = 1 if( length( $_ ) );
			last ENT if( eof( FILE ) );
		}
		close( FILE );
	}
}
if( $OPTIONS{"m"} ) {
	@EMPTY = split( m/,/, $OPTIONS{"m"} );
}
if( $OPTIONS{"o"} ) {
	$OPTIONS{"o"} = 1;
}
open( LOGFILE, ">CheckXML.log" ) if( $OPTIONS{l} );
foreach my $pathname ( @ARGV ) {
	if( -d $pathname ) {
		my $Directory = NetSoup::Files::Directory->new();
		$Directory->descend( Pathname    => $pathname,
												 Recursive   => 1,
												 Directories => 0,
												 Extensions  => $ACCEPTS,
												 Callback    => sub { checkfile( (shift) ) } );
	} elsif( -f $pathname ) {
		checkfile( $pathname );
	} elsif( $pathname ) {
		checkurl( $pathname );
	} else {
		print( qq(Error: "$pathname" is neither a file, directory or valid URL\n) );
	}
}
close( LOGFILE ) if( $OPTIONS{l} );
exit(0);


sub checkfile {
	my $pathname = shift;
	my $data     = "";
	my $Load     = NetSoup::Files::Load->new();
	$Load->load( Pathname => $pathname,
							 Data     => \$data );
	my $Entities = {};
	$Entities    = \%ENTITIES if( keys( %ENTITIES ) > 0 );
	my $Parser   = undef;
	if( $OPTIONS{H} ) {                                                # Use HTML compliant XML Parser
		$Parser = NetSoup::HTML::Parser->new( Debug   => $OPTIONS{d},
																					Strict  => $OPTIONS{"s"},
																					Orphans => 1 );
	} else {                                                           # Use regular XML Parser
		$Parser = NetSoup::XML::Parser->new( Debug    => $OPTIONS{d},
																				 Strict   => $OPTIONS{"s"},
																				 Orphans  => $OPTIONS{"o"},
																				 Entities => $Entities,
																				 Empty    => \@EMPTY );
	}
	return( check( $pathname, $Parser, \$data ) );
}


sub checkurl {
	my $url    = shift;
	my $HTTP   = NetSoup::Protocol::HTTP->new();
	my $Parser = NetSoup::HTML::Parser->new( Debug   => $OPTIONS{d},
																					 Strict  => $OPTIONS{"s"},
																					 Orphans => 1 );
	my $Document = $HTTP->get( URL => $url );
	if( ! defined $Document ) {
		print( STDERR  "HTTP Error\t" . $Document->status() . "\n" );
		print( LOGFILE "HTTP Error\t" . $Document->status() . "\n" ) if( $OPTIONS{l} );
	}
	my $data = $Document->body();
	return( check( $url, $Parser, \$data ) );
}


sub check {
	my $URI      = shift;
	my $Parser   = shift;
	my $XML      = shift;
	print( "$URI\n" ) if( $OPTIONS{d} );
	my $Document = $Parser->parse( XML => $XML );
	if( $Parser->flag( Flag => "Error" ) ) {
		print( "$URI\n" );
		print( LOGFILE "$URI\n" ) if( $OPTIONS{l} );
		foreach my $error ( $Parser->errors() ) {
			print( "$error\n" );
			print( LOGFILE "$error\n" ) if( $OPTIONS{l} );
		}
	} else {
		print( "$URI OK\n" ) if( $OPTIONS{v} );
		print( LOGFILE "$URI OK\n" ) if( $OPTIONS{l} && $OPTIONS{v} );
	}
	return(1);
}


__DATA__


CheckXML.pl - Checks XML documents for well-formedness.

Usage:

    CheckXML.pl [-dhlSsTv] [-efile] [-mempty,empty2] [ dir ... ] [ file ... ]

    -d  Display debugging messages

    -e  Specify entity translation table file

    -h  Display this help

    -H  Force HTML compliant XML Parser

    -l  Record log file to CheckXML.log

    -m  Comma seperated list of "empty" elements

    -o  Ignore "orphaned" elements

    -s  Use strict XML

    -v  Verbose mode

Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>


