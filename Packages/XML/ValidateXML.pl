#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::ValidateXML.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script applies the Validating
#                NetSoup XML Parser to one or more files, and
#                displays any errors encountered.


use strict;
use Getopt::Std;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::XML::Validator;
use NetSoup::XML::Util;


my $ACCEPTS  = NetSoup::XML::Util->accepts();
my %OPTIONS  = ();
my $HELP     = join( "", <DATA> );
my %ENTITIES = ();
getopt(  "e",      \%OPTIONS );
getopts( "dhlSTv", \%OPTIONS );
if( $OPTIONS{h} ) {
  print( $HELP );
  exit(0);
}
entities( $OPTIONS{e} ) if( $OPTIONS{e} );
open( LOGFILE, ">ValidateXML.log" ) if( $OPTIONS{l} );
warn( "****STARTING****\n" ) if( $OPTIONS{d} );
foreach my $pathname ( @ARGV ) {
  if( -d $pathname ) {
    my $Directory = NetSoup::Files::Directory->new();
    $Directory->descend( Pathname    => $pathname,
                         Recursive   => 1,
                         Directories => 0,
                         Extensions  => $ACCEPTS,
                         Callback    => sub { check( (shift) ) } );
  } elsif( -f $pathname ) {
    check( $pathname );
  } else {
    print( "Error\n" );
  }
}
close( LOGFILE ) if( $OPTIONS{l} );
warn( "****EXITING****\n" ) if( $OPTIONS{d} );
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


sub check {
  warn( "****START CHECK****\n" ) if( $OPTIONS{d} );
  my $pathname = shift;
  my $data     = "";
  my $Entities = {};
  $Entities    = \%ENTITIES if( keys( %ENTITIES ) > 0 );
  my $Load     = NetSoup::Files::Load->new();
  $Load->load( Pathname => $pathname,
               Data     => \$data );
  my $Validator = NetSoup::XML::Validator->new( Debug    => $OPTIONS{d},
                                                Entities => $Entities );
  print( "$pathname\n" ) if( $OPTIONS{d} );
  my $Document = $Validator->validate( XML => \$data,);
  if( $Validator->flag( Flag => "Error" ) ) {
    print( "$pathname\n" );
    print( LOGFILE "$pathname\n" ) if( $OPTIONS{l} );
    foreach my $error ( $Validator->errors() ) {
      print( "$error\n" );
      print( LOGFILE "$error\n" ) if( $OPTIONS{l} );
    }
  } else {
    print( "$pathname OK\n" ) if( $OPTIONS{v} );
    print( LOGFILE "$pathname OK\n" ) if( $OPTIONS{l} && $OPTIONS{v} );
  }
  $Validator->_DBSymbols() if( $OPTIONS{S} );
  $Validator->_DBSymbols() if( $OPTIONS{T} );
  warn( "****DONE CHECK****\n" ) if( $OPTIONS{d} );
  return(1);
}


__DATA__


ValidateXML.pl - Validates XML documents against their DTD

Usage:

    ValidateXML.pl [-dhSTv] dir1 [dir2...] file1 [file2...]

    -d  Display debugging messages

    -e  Specify entity translation table file

    -h  Display this help

    -l  Record log file to ValidateXML.log

    -S  Dump the Symbol Table to STDERR after the preprocessing phase

    -T  Dump the Parse Tree to STDERR after the compilation phase

    -v  Verbose mode

Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>


