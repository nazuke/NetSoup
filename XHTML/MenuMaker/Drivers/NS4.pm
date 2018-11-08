#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::NS4.pm v00.00.01a 12042000
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


package NetSoup::XHTML::MenuMaker::Drivers::NS4;
use strict;
use NetSoup::XHTML::MenuMaker::Drivers;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::File;
use NetSoup::XML::Parser;
@NetSoup::XHTML::MenuMaker::Drivers::NS4::ISA = qw( NetSoup::XHTML::MenuMaker::Drivers );
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
  my $NS4  = shift;         # Get NS4 object
  my %args = @_;            # Get arguments
  $NS4->SUPER::initialise;  # Initialise SUPER Class
  return( $NS4 );
}


sub build {
  my $NS4  = shift;  # Get NS4 object
  my %args     = @_;
  my $pathname = $args{Pathname} || "MenuMaker.xml";
  my $outfile  = $args{Target}   || "MenuMaker_NS4.html";
  my $Document = NetSoup::XML::File->new()->load( Pathname => $pathname );
  my $Shell    = NetSoup::XML::DOM2::Core::Document->new( DocumentElement => "ul" );  # In-memory XML menu document
  if( defined $Document ) {
    my $Form  = $Document->createElement( TagName => "form" );
    my $Table = $Document->createElement( TagName => "table" );
    $Table->setAttribute( Name => "border", Value => 0 );
    $Table->setAttribute( Name => "cellpadding", Value => 0 );
    $Table->setAttribute( Name => "cellspacing", Value => 0 );
    my $Tr = $Document->createElement( TagName => "tr" );
    my $Td = $Document->createElement( TagName => "td" );
    $Tr->appendChild( NewChild => $Td );
    $Table->appendChild( NewChild => $Tr );
    $Form->appendChild( NewChild => $Table );
    my $NodeList = $Document->getElementsByTagName( TagName => "menu" )->item( Item => 0 )->childNodes();
    for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
      print( "TOPLEVEL " . $NodeList->item( Item => $i )->getAttribute( Name => "name" ) . "\n" );
      if( $NodeList->item( Item => $i )->hasChildNodes() ) {
        my $funcname = "MM_f_" . $NS4->uniqid();
        my $function = <<FUNC;
        <!--
          function $funcname( obj ) {
            var url = obj.options[obj.selectedIndex].value;
            document.location = url;
          }
        //-->
FUNC
  ;
        my $Script = $Document->createElement( TagName => "script" );
        $Script->setAttribute( Name => "language", Value => "JavaScript" );
        $Script->setAttribute( Name => "type", Value => "text/javascript" );
        $Script->appendChild( NewChild => $Document->createTextNode( Data => $function ) );
        $Shell->appendChild( NewChild => $Script );
        my $Select = $Document->createElement( TagName => "select" );
        $Select->setAttribute( Name => "onChange", Value => "$funcname(this);" );
        $Select->setAttribute( Name => "class", Value => "MMsel" );
        my $OptionsNodeList = $NodeList->item( Item => $i )->getElementsByTagName( TagName => "item" );
        for( my $j = 0 ; $j < $OptionsNodeList->nodeListLength() ; $j++ ) {
          my $Option = $Document->createElement( TagName => "option" );
          $Option->setAttribute( Name => "value", Value => $OptionsNodeList->item( Item => $j )->getAttribute( Name => "href" ) );
          $Option->setAttribute( Name => "class", Value => "MMopt" );
          my $indent = '&nbsp;&nbsp;' x $OptionsNodeList->item( Item => $j )->nodeIndent();
          print( $indent . $OptionsNodeList->item( Item => $j )->getAttribute( Name => "name" ) . "\n" );
          my $Label = $Document->createTextNode( Data => $indent . $OptionsNodeList->item( Item => $j )->getAttribute( Name => "name" ) );
          $Option->appendChild( NewChild => $Label );
          $Select->appendChild( NewChild => $Option );
        }
        $Td->appendChild( NewChild => $Select );
      } else {
        my $Button = $Document->createElement( TagName => "input" );
        $Button->setAttribute( Name => "value",   Value => $NodeList->item( Item => $i )->getAttribute( Name => "name" ) );
        $Button->setAttribute( Name => "onClick", Value => qq(document.location=') . $NodeList->item( Item => $i )->getAttribute( Name => "href" ) . qq(';) );
        $Button->setAttribute( Name => "class",   Value => "MMopt" );
        $Button->setAttribute( Name => "type",    Value => "button" );
        $Td->appendChild( NewChild => $Button );
      }
    }
    $Shell->appendChild( NewChild => $Form );
  } else {
    print( STDERR "Error: Invalid XML Document\n" );
    return( undef );
  }
  # Remove the XML Processing Instruction
  $Shell->removeChild( OldChild => $Shell->firstChild() );
  # Write the Finished XML Document
  if( ! NetSoup::XML::File->new()->save( Pathname => $outfile,
                                         Document => $Shell,
                                         Compact  => 0 ) ) {
    print( STDERR "Error\n" );
  }
  return(1);
}
