#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::NodeList.pm v00.00.01a 12042000
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


package NetSoup::XML::DOM2::Core::NodeList;
use strict;
use NetSoup::Core;
@NetSoup::XML::DOM2::Core::NodeList::ISA = qw( NetSoup::Core );
my $MODULE = "NodeList";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # It initialises and returns a new DOM node object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $node
  # Example:
  #    my $node = NetSoup::XML::DOM::Parser::Node->new();
  my $NodeList           = shift;                      # Get NodeList object
  my %args               = @_;                         # Get arguments
  $NodeList->{Debug}     = $args{Debug} || 0;          # Set debugging flag
  $NodeList->{_Name}     = $args{_Name} || "NO_NAME";  # Get debugging name
  $NodeList->{NodeList}  = [];                         # List of Node objects
  $NodeList->{Length}    = -1;                         # Number of Node objects in NodeList
  $NodeList->{Populated} = 0;                          # Flags a populated list
  return( $NodeList );                                 # Return node object
}


sub appendNode {
  # This private method appends a node to the list.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node => $node
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    $NodeList->appendNode( Node => $node );
  my $NodeList           = shift;                 # Get NodeList object
  my %args               = @_;                    # Get arguments
  $NodeList->{Populated} = 1;                     # Raise flag
  push( @{$NodeList->{NodeList}}, $args{Node} );  # Append node to list
  return(1);
}


sub nodeListLength {
  # This method returns the length of the NodeList.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    int
  # Example:
  #    $NodeList->nodeListLength();
  my $NodeList = shift;                                     # Get NodeList object
  my %args     = @_;                                        # Get arguments
  my $length   = -1;
  if( $NodeList->{Populated} ) {                            # Check for populated NodeList
    $NodeList->{Length} = scalar @{$NodeList->{NodeList}};  # Compute length
  }
  return( $NodeList->{Length} );                            # Return length of NodeList
}


sub item {
  # This method returns an indexed Node object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Item => $item
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    $NodeList->item( Item => $item );
  my $NodeList = shift;                               # Get NodeList object
  my %args     = @_;                                  # Get arguments
  my $item     = int $args{Item};                     # Get item index
  return( $NodeList->{NodeList}->[$item] || undef );  # Return Node object
}


sub _insertBefore {
  # This private method inserts a new Node before the referenced Node in the NodeList.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NewNode => $newNode
  #              RefNode => $refNode
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    $NodeList->_insertBefore( NewNode => $newNode, RefNode => $refNode );
  my $NodeList = shift;                                    # Get NodeList object
  my %args     = @_;                                       # Get arguments
  my @holding  = ();                                       # Node holding array
  my $length   = $NodeList->nodeListLength();
  for( my $i = 0 ; $i < $length ; $i++ ) {                 # Search for reference Node
    if( $NodeList->{NodeList}->[$i] eq $args{RefNode} ) {  # Is this the Reference Node ?
      push( @holding, $args{NewNode} );                    # Push new Node onto holding array
    }
    push( @holding, $NodeList->{NodeList}->[$i] );         # Push Node onto holding array
  }
  $NodeList->{NodeList} = \@holding;                       # Relink NodeList array reference
  return(1);
}


sub _removeChild {
  # This private method removes the referenced Node in the NodeList.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              OldChild => $oldChild
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    $NodeList->_removeChild( OldChild => $oldChild );
  my $NodeList = shift;                                     # Get NodeList object
  my %args     = @_;                                        # Get arguments
  my @holding  = ();                                        # Node holding array
  my $length   = $NodeList->nodeListLength();
  for( my $i = 0 ; $i < $length ; $i++ ) {                  # Search for reference Node
    if( $NodeList->{NodeList}->[$i] ne $args{OldChild} ) {  # Is this the Node ?
      push( @holding, $NodeList->{NodeList}->[$i] );        # Push Node onto holding array
    }
  }
  $NodeList->{NodeList} = \@holding;                        # Relink NodeList array reference
  return(1);
}


sub DESTROY {
  my $NodeList = shift;
  undef @{$NodeList->{NodeList}};
  undef %{$NodeList};
  return(1);
}
