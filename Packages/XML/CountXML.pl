#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::CountXML.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script counts words in XML files.


use strict;
use Getopt::Std;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::XHTML::Util::CountWords;
use NetSoup::XML::Util;


my $ACCEPTS  = NetSoup::XML::Util->accepts();
my %OPTIONS  = ();
my %ENTITIES = ();
getopts( "dhlv", \%OPTIONS );
if( $OPTIONS{h} ) {
  print( join( "", <DATA> ) );
  exit(0);
}
open( LOGFILE, ">CountXML.log" ) if( $OPTIONS{l} );
foreach my $pathname ( @ARGV ) {
  my $Total = 0;
  if( -d $pathname ) {
    my $Directory = NetSoup::Files::Directory->new();
    $Directory->descend( Pathname    => $pathname,
                         Recursive   => 1,
                         Directories => 0,
                         Extensions  => $ACCEPTS,
                         Callback    => sub { $Total += count( (shift) ) } );
  } elsif( -f $pathname ) {
    $Total += count( $pathname );
  } else {
    print( "Error\n" );
  }
  print( "\nTotal $Total words in $pathname\n" ) if( $OPTIONS{v} );
  print( LOGFILE "\nTotal $Total words in $pathname\n" ) if( $OPTIONS{l} && $OPTIONS{v} );
}
close( LOGFILE ) if( $OPTIONS{l} );
exit(0);


sub entities {
  my $pathname = shift;
  if( open( FILE, $pathname ) ) {
    ENT: while( <FILE> ) {
      chomp;
      $ENTITIES{$_} = 1 if( length( $_ ) );
      last ENT if( eof( FILE ) );
    }
    close( FILE );
  }
  return(1);
}


sub count {
  my $pathname = shift;
  my $data     = "";
  my $Load     = NetSoup::Files::Load->new();
  $Load->load( Pathname => $pathname,
               Data     => \$data );
  my $CountWords = NetSoup::XHTML::Util::CountWords->new();
  my $count      = $CountWords->countxml( Debug => $OPTIONS{d},
                                          XML   => \$data );
  print( "$count\tword(s) in $pathname\n" ) if( $OPTIONS{v} );
  print( LOGFILE "$count\tword(s) in $pathname\n" ) if( $OPTIONS{l} && $OPTIONS{v} );
  return( $count );
}


__DATA__


CountXML.pl - Counts the number of words in an XML document.

Usage:

    CountXML.pl [-dhlv] dir1 [dir2...] file1 [file2...]

    -d  Display debugging messages

    -h  Display this help

    -l  Record log file to CountXML.log

    -v  Verbose mode

Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>


