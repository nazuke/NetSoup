#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::Entity.pm v00.00.01z 12042000
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


package NetSoup::XML::DOM2::Core::Entity;
use strict;
use NetSoup::Core;
use NetSoup::XML::DOM2::Core::Node;
@NetSoup::XML::DOM2::Core::Entity::ISA = qw( NetSoup::XML::DOM2::Core::Node );
my $MODULE = "Entity";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              PublicId     => $PublicId
  #              SystemId     => $SystemId
  #              NotationName => $NotationName
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Entity = NetSoup::XML::DOM2::Core::Entity->new();
  my $Entity                      = shift;                # Get Entity object
  my %args                        = @_;                   # Get arguments
  $Entity->SUPER::initialise( %args );                    # Perform base class initialisation
  $Entity->{Node}->{NodeName}     = "ENTITY_NODE";        # Set Node name
  $Entity->{Node}->{NodeType}     = "ENTITY_NODE";        # Set Node type
  $Entity->{Node}->{PublicId}     = $args{PublicId};      # Type String
  $Entity->{Node}->{SystemId}     = $args{SystemId};      # Type String
  $Entity->{Node}->{NotationName} = $args{NotationName};  # Type String
  return( $Entity );                                      # Return Entity object
}
