#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::NamedNodeMap.pm v00.00.01z 12042000
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
#       method  -  description


package NetSoup::XML::DOM2::Core::NamedNodeMap;
use strict;
use NetSoup::Core;
@NetSoup::XML::DOM2::Core::NamedNodeMap::ISA = qw( NetSoup::Core );
my $MODULE = "NamedNodeMap";
1;


sub initialise {
  # This method is the node initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Debug => 0 | 1
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $NamedNodeMap = NetSoup::XML::DOM::Parser::NamedNodeMap->new();
  my $NamedNodeMap        = shift;                      # Get object
  my %args                = @_;                         # Get arguments
  $NamedNodeMap->{Debug}  = $args{Debug} || 0;          # Set debugging flag
  $NamedNodeMap->{_Name}  = $args{_Name} || "NO_NAME";  # Get debugging name
  $NamedNodeMap->{Length} = -1;                         # Initialise number of named objects
  $NamedNodeMap->{Nodes}  = [];                         # Array of named node objects
  return( $NamedNodeMap );                              # Return NamedNodeMap object
}


sub namedNodeMapLength {
  # This method is the node initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $length = $NamedNodeMap->namedNodeMapLength();
  my $NamedNodeMap = shift;           # Get object
  my %args         = @_;              # Get arguments
  return( $NamedNodeMap->{Length} );  # Return number of items
}


sub getNamedItem {
  # This method returns a named node object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $item = $NamedNodeMap->getNamedItem( Name => $name );
  my $NamedNodeMap = shift;                                    # Get object
  my %args         = @_;                                       # Get arguments
  my $name         = $args{Name};                              # Get name of required node object
  my $length       = $NamedNodeMap->{Length};                  # Initialise number of named objects
  my $Node         = undef;
  return( undef ) if( $length == -1 );
 SEARCH: for( my $i = 0 ; $i <= $length ; $i++ ) {             # Search for named node
    last SEARCH if( ! defined $NamedNodeMap->{Nodes}->[$i] );  #
    my $thisName = $NamedNodeMap->{Nodes}->[$i]->nodeName();   # Get node name
    if( $name eq $thisName ) {                                 # Compare names
      $Node = $NamedNodeMap->{Nodes}->[$i];
      last SEARCH;
    }
  }
  return( $Node );                                             # Return named node object
}


sub setNamedItem {
  # This method creates a new named node object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node => $Node
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $item = $NamedNodeMap->setNamedItem( Node => $Node );
  my $NamedNodeMap = shift;                                                                      # Get object
  my %args         = @_;                                                                         # Get arguments
  my $Node         = $args{Node};                                                                # Get node object
  my $name         = $Node->nodeName();                                                          # Get node name
  if( $NamedNodeMap->getNamedItem( Name => $name ) ) {                                           # Check for existing named node
    $NamedNodeMap->getNamedItem( Name => $name )->nodeValue( NodeValue => $Node->nodeValue() );  # Reset existing value
  } else {
    $NamedNodeMap->{Length}++;                                                                   # Increment number of named objects
    $NamedNodeMap->{Nodes}->[$NamedNodeMap->{Length}] = $Node;                                   # Set item named node
  }
  return( $Node );
}


sub removeNamedItem {
  # This method deletes a named node object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    $NamedNodeMap->removeNamedItem( Name => $name );
  my $NamedNodeMap = shift;                                    # Get object
  my %args         = @_;                                       # Get arguments
  my $name         = $args{Name};                              # Get name of node to delete
 FIND: for( my $i = 0 ; $i < @{$NamedNodeMap->{Nodes}} ; $i++ ) {                     # Search for reference Node
    if( $NamedNodeMap->{Nodes}->[$i]->nodeName() eq $name ) {  # Is this the Node ?
      splice( @{$NamedNodeMap->{Nodes}}, $i, 1 );
      last FIND;
    }
  }
  $NamedNodeMap->{Length} = @{$NamedNodeMap->{Nodes}} - 1;
  return( $NamedNodeMap );
}


sub item {
  # This method returns an indexed named node object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Index => $index
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $item = $NamedNodeMap->item( Index => $index );
  my $NamedNodeMap = shift;                             # Get object
  my %args         = @_;                                # Get arguments
  my $index        = $args{Index};                      # Get index of object
  my $Node         = $NamedNodeMap->{Nodes}->[$index];  # Extract Node object
  return( $Node || undef );                             # Return indexed Node object
}


sub getNamedItemNS {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method is the node initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NamespaceURI => $namespaceURI
  #              LocalName    => $localName
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $item = $NamedNodeMap->getNamedItem( Name => $name );
  my $NamedNodeMap = shift;              # Get object
  my %args         = @_;                 # Get arguments
  my $name         = $args{Name} || "";  # Get name of object

  return();
}


sub setNamedItemNS {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method is the node initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node => $Node
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $item = $NamedNodeMap->getNamedItem( Name => $name );
  my $NamedNodeMap = shift;              # Get object
  my %args         = @_;                 # Get arguments
  my $name         = $args{Name} || "";  # Get name of object

  return();
}


sub removeNamedItemNS {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method is the node initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NamespaceURI => $namespaceURI
  #              LocalName    => $localName
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $item = $NamedNodeMap->getNamedItem( Name => $name );
  my $NamedNodeMap = shift;              # Get object
  my %args         = @_;                 # Get arguments
  my $name         = $args{Name} || "";  # Get name of object

  return();
}


sub DESTROY {
  my $NamedNodeMap = shift;
  do {
    shift @{$NamedNodeMap->{Nodes}};
  } while( @{$NamedNodeMap->{Nodes}} );
  delete $NamedNodeMap->{Nodes};
  return(1);
}
