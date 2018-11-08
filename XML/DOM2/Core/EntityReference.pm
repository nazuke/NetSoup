#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::EntityReference.pm v00.00.01z 12042000
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


package NetSoup::XML::DOM2::Core::EntityReference;
use strict;
use NetSoup::Core;
use NetSoup::XML::DOM2::Core::Node;
@NetSoup::XML::DOM2::Core::EntityReference::ISA = qw( NetSoup::XML::DOM2::Core::Node );
my $MODULE = "EntityReference";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              Key => $Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $EntityReference = NetSoup::XML::DOM2::Core::EntityReference->new();
  my $EntityReference                  = shift;                    # Get EntityReference object
  my %args                             = @_;                       # Get arguments
  $EntityReference->SUPER::initialise( %args );                    # Perform base class initialisation
  $EntityReference->{Node}->{NodeName} = "ENTITY_REFERENCE_NODE";  # Set Node name
  $EntityReference->{Node}->{NodeType} = "ENTITY_REFERENCE_NODE";  # Set Node type
  return( $EntityReference );                                      # Return EntityReference object
}
