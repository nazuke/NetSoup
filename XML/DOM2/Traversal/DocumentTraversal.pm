#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Traversal::DocumentTraversal.pm v00.00.01a 12042000
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


package NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use strict;
use NetSoup::Core;
use NetSoup::XML::DOM2::Traversal::NodeIterator;
use NetSoup::XML::DOM2::Traversal::TreeWalker;
use NetSoup::XML::DOM2::Traversal::Serialise;
@NetSoup::XML::DOM2::Traversal::DocumentTraversal::ISA = qw( NetSoup::Core );
my $NODEITERATOR = "NetSoup::XML::DOM2::Traversal::NodeIterator";
my $TREEWALKER   = "NetSoup::XML::DOM2::Traversal::TreeWalker";
my $SERIALISE    = "NetSoup::XML::DOM2::Traversal::Serialise";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $DocumentTraversal = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
  my $DocumentTraversal = shift;  # Get element object
  my %args              = @_;     # Get arguments
  return( $DocumentTraversal );   # Return blessed DocumentTraversal object
}


sub createNodeIterator {
  # This method returns a NodeIterator.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              Root                     => $Node
  #              WhatToShow               => $whatToShow
  #              Filter                   => sub {}
  #              EntityReferenceExpansion => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $NodeIterator = $DocumentTraversal->createNodeIterator();
  my $DocumentTraversal = shift;          # Get element object
  my %args              = @_;             # Get arguments
  return( $NODEITERATOR->new( %args ) );  # Create and return new NodeIterator object
}


sub createTreeWalker {
  # This method returns a TreeWalker.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              Root                     => $Node
  #              WhatToShow               => $whatToShow
  #              Filter                   => sub {}
  #              EntityReferenceExpansion => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $TreeWalker = $DocumentTraversal->createTreeWalker();
  my $DocumentTraversal = shift;        # Get element object
  my %args              = @_;           # Get arguments
  return( $TREEWALKER->new( %args ) );  # Create and return new TreeWalker object
}


sub createSerialise {
  # This method returns a Serialise.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              Root                     => $Node
  #              WhatToShow               => $whatToShow
  #              Filter                   => sub {}
  #              EntityReferenceExpansion => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Serialise = $DocumentTraversal->createSerialise();
  my $DocumentTraversal = shift;       # Get element object
  my %args              = @_;          # Get arguments
  return( $SERIALISE->new( %args ) );  # Create new Serialise object
}
