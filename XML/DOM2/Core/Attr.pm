#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::Attr.pm v00.00.01z 12042000
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


package NetSoup::XML::DOM2::Core::Attr;
use strict;
use NetSoup::Core;
use NetSoup::XML::DOM2::Core::Node;
@NetSoup::XML::DOM2::Core::Attr::ISA = qw( NetSoup::XML::DOM2::Core::Node );
my $MODULE = "Attr";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              Name         => $name
  #              Specified    => $specified
  #              Value        => $value
  #              OwnerElement => $ownerElement
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Attr = NetSoup::XML::DOM2::Core::Attr->new();
  my $Attr                      = shift;                # Get Attr object
  my %args                      = @_;                   # Get arguments
  $Attr->SUPER::initialise( %args );                    # Perform base class initialisation
  $Attr->{Node}->{NodeName}     = "ATTRIBUTE_NODE";     # Set node type
  $Attr->{Node}->{Name}         = $args{Name};          # Type String
  $Attr->{Node}->{Specified}    = $args{Specified};     # Type boolean
  $Attr->{Node}->{Value}        = $args{Value};         # Type String
  $Attr->{Node}->{OwnerElement} = $args{OwnerElement};  # Type Element
  return( $Attr );                                      # Return Attr object
}


sub xDESTROY {
  # This method is the object destructor for this class.
  my $Attr = shift;
  warn( "DESTROYING ATTR $Attr\n" ) if( $Attr->{Debug} );
  $Attr->SUPER::DESTROY();
  $Attr->{Node}->{OwnerElement} = {};
  return(1);
}
