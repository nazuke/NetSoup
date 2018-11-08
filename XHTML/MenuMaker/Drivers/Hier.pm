#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::Hier.pm v00.00.01a 12042000
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


package NetSoup::XHTML::MenuMaker::Drivers::Hier;
use strict;
use NetSoup::Files::Save;
use NetSoup::XHTML::MenuMaker::Drivers;
use NetSoup::XML::File;
use NetSoup::XML::Parser;
@NetSoup::XHTML::MenuMaker::Drivers::Hier::ISA = qw( NetSoup::XHTML::MenuMaker::Drivers );
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
  my $Hier = shift;  # Get Hier object
  my %args = @_;     # Get arguments
  $Hier->SUPER::initialise;
  return( $Hier );
}


sub build {
  my $Hier     = shift;  # Get Hier object
  my %args     = @_;
  my $pathname = $args{Pathname} || "MenuMaker.xml";
  my $outfile  = $args{Target}   || "MenuMaker.html";
  my $Document = NetSoup::XML::File->new()->load( Pathname => $pathname );
  my $HTML     = "";
  if( defined $Document ) {




    {  # Create Top Level Navigator
      my $TEMPLATE = qq(<p>__TOPLEVEL__</p>\n);
      my $NodeList = $Document->getElementsByTagName( TagName => "item" );
      my @TopLevel = ();
      for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
        my $Node = $NodeList->item( Item => $i );
        if( $Node->nodeIndent() == 1 ) {
          print( $Node->nodeIndent() . " " . $Node->getAttribute( Name => "name" ) . "\n" );
          push( @TopLevel, "<a href=\"" . $Node->getAttribute( Name => "hierhref" ) . "\">" . $Node->getAttribute( Name => "name" ) . "</a>" );
        }
      }
      my $TopLevel = join( " : ", @TopLevel );
      $TEMPLATE    =~ s:__TOPLEVEL__:$TopLevel:gs;
      $HTML       .= $TEMPLATE;
    }




    {  # Create Path Navigators
      my $TEMPLATE = <<TEMPLATE;
<!--\#if expr="\\"\$REQUEST_URI\\" = \\"__REQUEST_URI__\\"" -->
<p>__PEERS__</p>
<p>__LIST__</p>
<!--\#endif -->
TEMPLATE
      my $NodeList = $Document->getElementsByTagName( TagName => "item" );
      for( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
        my $Node        = $NodeList->item( Item => $i );
        print( $Node->nodeName() . " " . $Node->nodeIndent() . ( "    " x $Node->nodeIndent() ) . $Node->getAttribute( Name => "name" ) . "\n" );
        my $REQUEST_URI = $Node->getAttribute( Name => "href" ) || "X0";
        my $Parent      = $Node->parentNode();
        my @Peers       = ();
        my @List        = ();
        my $Template    = $TEMPLATE;
        unshift( @List, "<a href=\"" . $Node->getAttribute( Name => "href" ) . "\">" . $Node->getAttribute( Name => "name" ) . "</a>" );
        

        my $PeersNodeList = $Node->parentNode()->childNodes();
        for( my $j = 0 ; $j < $PeersNodeList->nodeListLength() ; $j++ ) {
          my $Peer        = $PeersNodeList->item( Item => $j );
          push( @Peers, "<a href=\"" . $Peer->getAttribute( Name => "href" ) . "\">" . $Peer->getAttribute( Name => "name" ) . "</a>" );
        }


        while( ( defined $Parent ) && ( $Parent->nodeName() eq "item" ) ) {
          print( $Parent->nodeName() . " " . $Parent->nodeIndent() . ( "    " x $Parent->nodeIndent() ) . $Parent->getAttribute( Name => "name" ) . "\n" );
          unshift( @List, "<a href=\"" . ( $Parent->getAttribute( Name => "href" ) || $Node->getAttribute( Name => "hierhref" ) ) . "\">" . $Parent->getAttribute( Name => "name" ) . "</a>" );
          $Parent = $Parent->parentNode();
        }
        unshift( @List, qq(<a href="/">/</a>) );
        
        
        my $Peers = join( " : ", @Peers );
        my $List  = join( " : ", @List );
        $Template =~ s:__PEERS__:$Peers:gs;
        $Template =~ s:__LIST__:$List:gs;
        $Template =~ s/__REQUEST_URI__/$REQUEST_URI/gs;
        $HTML    .= $Template;
      }
    }
  } else {
    print( STDERR "Error: Invalid XML Document\n" );
    return( undef );
  }
  # Write the Finished XML Document
  if( ! NetSoup::Files::Save->new()->save( Pathname => $outfile, Data=> \$HTML ) ) {
    print( STDERR "Error\n" );
  }
  return(1);
}
