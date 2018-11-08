#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::CompareXML.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script compares two XML DOM trees.


use strict;
use Getopt::Std;
use NetSoup::Files::Load;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;


my %OPTIONS = ();
getopt( "O", \%OPTIONS );
getopt( "N", \%OPTIONS );
getopts( "dhl", \%OPTIONS );
if( $OPTIONS{h} ) {
  print( join( "", <DATA> ) );
  exit(0);
}
compare( $OPTIONS{O}, $OPTIONS{N} );
exit(0);


sub compare {
  my $oldfile = shift;
  my $newfile = shift;
  my %Data    = ( Old     => "",
                  OldList => [],
                  New     => "",
                  NewList => [] );
  my $Load    = NetSoup::Files::Load->new();
  my $DT      = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
  $Load->load( Pathname => $oldfile, Data => \$Data{Old} );
  $Load->load( Pathname => $newfile, Data => \$Data{New} );
  my $OldParser   = NetSoup::XML::Parser->new();
  my $NewParser   = NetSoup::XML::Parser->new();
   my $OldDocument = $OldParser->parse( XML        => \$Data{Old},
                                       Whitespace => "compact" );
   my $NewDocument = $NewParser->parse( XML        => \$Data{New},
                                       Whitespace => "compact" );
  foreach my $Parser ( $OldParser, $NewParser ) {
    if( $Parser->flag( Flag => "Error" ) ) {
      foreach my $error ( $Parser->errors() ) {
        print( STDERR $error );
      }
      return( undef );
    }
  }
  my $OldTW = $DT->createTreeWalker( CurrentNode              => $OldDocument,
                                     WhatToShow               => undef,
                                     Filter                   => undef,
                                     EntityReferenceExpansion => 0 );
  my $NewTW = $DT->createTreeWalker( CurrentNode              => $NewDocument,
                                     WhatToShow               => undef,
                                     Filter                   => undef,
                                     EntityReferenceExpansion => 0 );
  $OldTW->walkTree( Node     => $OldDocument,
                    Callback => sub {
                      my $Node = shift;
                      push( @{$Data{OldList}}, $Node->nodeName() );
                      return(1);
                    } );
  $NewTW->walkTree( Node     => $NewDocument,
                    Callback => sub {
                      my $Node = shift;
                      push( @{$Data{NewList}}, $Node->nodeName() );
                      return(1);
                    } );
  my $OldLength = @{$Data{OldList}};
  my $NewLength = @{$Data{NewList}};
  print( "$OldLength\t$NewLength\n" );
  if( $OldLength == $NewLength ) {
    for( my $i = 0 ; $i <= $OldLength ; $i++ ) {
      print( "$Data{OldList}->[$i]\t$Data{NewList}->[$i]\n" );
    }
  }
  return(1);
}


__DATA__


CompareXML.pl - Compares the parse trees of two XML documents.

Usage:

    CheckXML.pl [-dhl] -Ooldfile -Nnewfile

    -d  Display debugging messages

    -O  Specify the old file

    -N  Specify the new file

    -h  Display this help

    -l  Record log file to CheckXML.log

Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>


