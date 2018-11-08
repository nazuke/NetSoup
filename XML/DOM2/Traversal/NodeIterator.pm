#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Traversal::NodeIterator.pm v00.00.01z 12042000
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


package NetSoup::XML::DOM2::Traversal::NodeIterator;
use strict;
use NetSoup::Core;
@NetSoup::XML::DOM2::Traversal::NodeIterator::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Root                   => $node
  #              WhatToShow             => $whatToShow
  #              Filter                 => sub {}
  #              ExpandEntityReferences => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $NodeIterator = NetSoup::XML::DOM2::Traversal::NodeIterator->new();
  my $NodeIterator                        = shift;                                    # Get element object
  my %args                                = @_;                                       # Get arguments
  $NodeIterator->{Root}                   = $args{Root};                              # Type Node
  $NodeIterator->{WhatToShow}             = $args{WhatToShow}             || 0;       # Type long
  $NodeIterator->{Filter}                 = $args{Filter}                 || sub {};  # Type NodeFilter
  $NodeIterator->{ExpandEntityReferences} = $args{ExpandEntityReferences} || 0;       # Type boolean
  $NodeIterator->{NextNode}               = { Node => $NodeIterator->{Root} };        # Points to next Node in document
  return( $NodeIterator );                                                            # Return blessed NodeIterator object
}


sub nextNode {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $node
  # Example:
  #    my $Node = $NodeIterator->nextNode();
  my $NodeIterator                  = shift;                                                 # Get NodeIterator object
  my %args                          = @_;                                                    # Get arguments
  my $node                          = $NodeIterator->{NextNode}->{Node} || return( undef );  # Get current Node or end reached


  $NodeIterator->{NextNode}->{Node} = $node->nextSibling();                                  # Get next sibling Node


  return( $node );                                                                           # Return Node object
}


sub previousNode {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Node = $NodeIterator->nextNode();
  my $NodeIterator = shift;                       # Get NodeIterator object
  my %args         = @_;                          # Get arguments
  my $node         = $NodeIterator->{_NextNode};  # Get current Node


  return( $node );                                # Return Node object
}


sub detach {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Node = $NodeIterator->nextNode();
  my $NodeIterator = shift;                       # Get NodeIterator object
  my %args         = @_;                          # Get arguments
  my $node         = $NodeIterator->{_NextNode};  # Get current Node

  return( $node );                                # Return Node object
}
