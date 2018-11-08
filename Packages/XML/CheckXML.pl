#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::CheckXML.pl v01.00.00a
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
use Getopt::Std;
use LWP::Simple;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::Protocol::HTTP;
use NetSoup::Protocol::HTTP::Spider;
use NetSoup::HTML::Parser;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use NetSoup::XML::Util;


my $ACCEPTS  = NetSoup::XML::Util->accepts();
my %OPTIONS  = ();
my %ENTITIES = ();
my @EMPTY    = ();
getopt(  "empu",     \%OPTIONS );
getopts( "dhHlrstTv", \%OPTIONS );
if( ( ! @ARGV ) || $OPTIONS{h} ) {
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
$OPTIONS{"o"} = 1 if( $OPTIONS{"o"} );
if( defined $OPTIONS{"s"} ) {
  $OPTIONS{"s"} = "yes";
} else {
  $OPTIONS{"s"} = "no";
}
$OPTIONS{"t"} = "no"  if( $OPTIONS{"t"} );
open( LOGFILE, ">CheckXML.log" ) if( $OPTIONS{l} );
foreach my $pathname ( @ARGV ) {
  my $Parser   = undef;
  my $Entities = {};
  $Entities    = \%ENTITIES if( keys( %ENTITIES ) > 0 );
  if( ( $OPTIONS{"s"} eq "no") && $OPTIONS{H} ) {                        # Use HTML compliant XML Parser
    $OPTIONS{T} = 0;                                                     # Disable parse tree dump
    $Parser     = NetSoup::HTML::Parser->new( Debug   => $OPTIONS{d},
                                              Strict  => $OPTIONS{"s"},
                                              Orphans => 1 );
  } else {                                                               # Use regular XML Parser
    $Parser = NetSoup::XML::Parser->new( Debug     => $OPTIONS{d},
                                         Strict    => $OPTIONS{"s"},
                                         Orphans   => $OPTIONS{"o"},
                                         Entities  => $Entities,
                                         Empty     => \@EMPTY,
                                         ParseText => $OPTIONS{"t"} );
  }
  if( -d $pathname ) {
    my $Directory = NetSoup::Files::Directory->new();
    $Directory->descend( Pathname    => $pathname,
                         Recursive   => 1,
                         Directories => 0,
                         Extensions  => $ACCEPTS,
                         Callback    => sub { checkfile( (shift) ) } );
  } elsif( -f $pathname ) {
    checkfile( $pathname, $Parser );
  } elsif( $pathname ) {
    checkurl( $pathname, $Parser );
  } else {
    print( qq(Error: "$pathname" is neither a file, directory or valid URL\n) );
  }
}
close( LOGFILE ) if( $OPTIONS{l} );
exit(0);


sub checkfile {
  my $pathname = shift;
  my $Parser   = shift;
  my $data     = "";
  my $Load     = NetSoup::Files::Load->new();
  $Load->load( Pathname => $pathname, Data => \$data );
  return( check( $pathname, $Parser, \$data ) );
}


sub checkurl {
  my $url    = shift;
  my $Parser = shift;
  if( $OPTIONS{"r"} ) {
    my $Spider = NetSoup::Protocol::HTTP::Spider->new();
    $Spider->spider( Depth    => 9999,
                     URL      => $url,
                     Parser   => $Parser,
                     Callback => sub {
                       my %args = @_;
                       check( $args{URL}, $Parser, \$args{HTML} );
                       return(1);
                     } );
  } else {
    my $HTTP     = NetSoup::Protocol::HTTP->new();
    my $Document = $HTTP->get( URL      => $url,
                               Username => $OPTIONS{"u"},
                               Password => $OPTIONS{"p"} );
    if( defined $Document ) {
      my $data = $Document->body();
      if( $Document->status() =~ m/200/ ) {
        return( check( $url, $Parser, \$data ) );
      } else {
        print( "$url\n\tError: " . $Document->status() . "\n" );
        print( LOGFILE "$url\n\tError: " . $Document->status() . "\n" ) if( $OPTIONS{l} );
        return( undef );
      }
    } else {
      print( STDERR  qq($url\n\tHTTP Error: ") . $HTTP->status() . qq("\n) );
      print( LOGFILE qq($url\n\tHTTP Error: ") . $HTTP->status() . qq("\n) ) if( $OPTIONS{l} );
    }
  }
  return( undef );
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
    print( "$URI OK\n" ) if( $OPTIONS{"v"} );
    print( LOGFILE "$URI OK\n" ) if( $OPTIONS{"l"} && $OPTIONS{"v"} );
    if( $OPTIONS{T} && defined $Document ) {
      my $DT         = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
      my $TreeWalker = $DT->createTreeWalker( CurrentNode              => $Document,
                                              WhatToShow               => undef,
                                              Filter                   => sub { return(1) },
                                              EntityReferenceExpansion => 0 );
      $TreeWalker->walkTree( Node     => $Document,
                             Callback => sub {
                               my $Node   = shift;
                               my $indent = $Node->nodeIndent();
                               print( ( "\t" x $indent . $Node->nodeName() || "" ) . "\n" );
                               return(1);
                             } );
    }
  }
  return(1);
}


__DATA__


CheckXML - Checks XML documents for well-formedness.

Usage:

    CheckXML.pl [-dhlpsuv] [-efile] [-mempty,empty2] [dir1,dir2] [file1,file2]

    -d  Display debugging messages

    -e  Specify entity translation table file

    -h  Display this help

    -H  Force HTML compliant mode Parser

    -l  Record log file to CheckXML.log

    -m  Comma seperated list of "empty" elements

    -o  Ignore "orphaned" elements

    -p  Login password string

    -r  Check recursively via HTTP

    -s  Use strict XML

    -t  Disable parsing of text elements

    -T  Dump XML parse tree to STDOUT after parsing

    -u  Login username string

    -v  Verbose mode

Copyright (C) 2001  Jason Holland <jason.holland@dial.pipex.com>


