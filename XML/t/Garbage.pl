#!/usr/local/bin/perl -w
#
#   NetSoup::XML::t::Garbage.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the XML DOM classes.


use strict;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::XML::Parser;
use NetSoup::XML::Util;
use Getopt::Std;


my $ACCEPTS = NetSoup::XML::Util->accepts();
my %OPTIONS = ();
my $HELP    = join( "", <DATA> );
getopt(  "n",  \%OPTIONS );
getopts( "pc", \%OPTIONS );
if( $OPTIONS{h} ) {
  print( $HELP );
  exit(0);
}
my $count = $OPTIONS{n} || 5;
my $data     = "";
my $Load     = NetSoup::Files::Load->new();
$Load->load( Pathname => $ARGV[0],
             Data     => \$data );
if( $OPTIONS{p} ) {
  while( $count ) {
    print( "$ARGV[0]\t$count\n" );
    preprocessor( \$data );
    $count--;
  }
} elsif( $OPTIONS{c} ) {
  my $Parser = NetSoup::XML::Parser->new();
  my $PP     = $Parser->_preprocessor( Debug      => 0,
                                       XML        => \$data,
                                       Symbols    => [] );
  while( $count ) {
    compiler( \$data );
    $count--;
  }
} else {
  while( $count ) {
    print( "$ARGV[0]\t$count\n" );
    both( \$data );
    $count--;
  }
}
exit(0);


sub preprocessor {
  my $data   = shift;
  my $Parser = NetSoup::XML::Parser->new();
  my $PP     = $Parser->_preprocessor( Debug      => 0,
                                       XML        => $data,
                                       Symbols    => [] );
  if( $Parser->flag( Flag => "Error" ) ) {
    foreach my $error ( $Parser->errors() ) {
      print( "$error\n" );
    }
  }
  undef( $PP );
  return(1);
}


sub compiler {
  my $data     = shift;
  my $Parser   = NetSoup::XML::Parser->new();
  my $Document = $Parser->parse( Debug => 0,
                                 XML   => $data );
  if( $Parser->flag( Flag => "Error" ) ) {
    foreach my $error ( $Parser->errors() ) {
      print( "$error\n" );
    }
  }
  return(1);
}


sub both {
  my $data     = shift;
  my $Parser   = NetSoup::XML::Parser->new();
  my $Document = $Parser->parse( Debug => 0,
                                 XML   => $data );
  if( $Parser->flag( Flag => "Error" ) ) {
    foreach my $error ( $Parser->errors() ) {
      print( "$error\n" );
    }
  }
  return(1);
}


__DATA__


Garbage.pl - Testing Garbage Collection

Usage:

    Garbage.pl [-n %d] [-pc] file1

    -n  Number of test iterations

    -p  Test the preprocessor

    -c  Test the compiler


Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>


