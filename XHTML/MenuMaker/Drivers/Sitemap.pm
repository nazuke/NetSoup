#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::Sitemap.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class provides object methods for.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class


package NetSoup::XHTML::MenuMaker::Drivers::Sitemap;
use strict;
use NetSoup::XHTML::MenuMaker::Drivers;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::File;
use NetSoup::XML::Parser;
@NetSoup::XHTML::MenuMaker::Drivers::Sitemap::ISA = qw( NetSoup::XHTML::MenuMaker::Drivers );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Sitemap = shift;          # Get Sitemap object
  my %args    = @_;             # Get arguments
  $Sitemap->SUPER::initialise;
  return( $Sitemap );
}


sub build {
  my $Sitemap  = shift;  # Get Sitemap object
  my %args     = @_;
  my $pathname = $args{Pathname} || "MenuMaker.xml";
  my $outfile  = $args{Target}   || "MenuMaker_Sitemap.html";
  my $Document = NetSoup::XML::File->new()->load( Pathname => $pathname );
  my $Shell    = NetSoup::XML::DOM2::Core::Document->new( DocumentElement => "ul" );  # In-memory XML menu document
  if( defined $Document ) {
    $Sitemap->traverse( Document => $Document,
                        NodeList => $Document->getElementsByTagName( TagName => "menu" )->item( Item => 0 )->childNodes(),
                        Shell    => $Shell );
  } else {
    print( STDERR "Error: Invalid XML Document\n" );
    return( undef );
  }
  $Shell->removeChild( OldChild => $Shell->firstChild() ); # Remove the XML Processing Instruction
  # Write the Finished XML Document
  if( ! NetSoup::XML::File->new()->save( Pathname => $outfile,
                                         Document => $Shell,
                                         Compact  => 0 ) ) {
    print( STDERR "Error\n" );
  }
  return(1);
}


sub traverse {
  my $Sitemap  = shift;
  my %args     = @_;
  my $Document = $args{Document};
  my $NodeList = $args{NodeList};
  my $Shell    = $args{Shell},
  my $UL       = $Document->createElement( TagName => "ul" );
  for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
    my $LI = $Document->createElement( TagName => "li" );
    print( STDERR "    " x $NodeList->item( Item => $i )->nodeIndent() . $NodeList->item( Item => $i )->getAttribute( Name => "name" ) . "\n" );
    if( $NodeList->item( Item => $i )->getAttribute( Name => "href" ) ) {
      my $A    = $Document->createElement( TagName => "a" );
      my $TEXT = $Document->createTextNode( Data => $NodeList->item( Item => $i )->getAttribute( Name => "name" ) );
      $A->setAttribute( Name => "href", Value => $NodeList->item( Item => $i )->getAttribute( Name => "href" ) );
      $A->appendChild( NewChild => $TEXT );
      $LI->appendChild( NewChild => $A );
    } else {
      my $TEXT = $Document->createTextNode( Data => $NodeList->item( Item => $i )->getAttribute( Name => "name" ) );
      $LI->appendChild( NewChild => $TEXT );
    }
    if( $NodeList->item( Item => $i )->hasChildNodes() ) {
      $Sitemap->traverse( Document => $Document,
                          NodeList => $NodeList->item( Item => $i )->childNodes(),
                          Shell    => $LI );
    }
    $UL->appendChild( NewChild => $LI );
  }
  $Shell->appendChild( NewChild => $UL );
  return(1);
}
