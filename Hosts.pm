#!/usr/local/bin/perl
#
#   NetSoup::Hosts.pm v00.00.01a 12042000
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


package NetSoup::Hosts;
use strict;
use NetSoup::Core;
@NetSoup::Hosts::ISA = qw( NetSoup::Core );
1;


sub getHostname {
  # This method returns the hostname.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    scalar    hostname to lookup
  # Result Returned:
  #    scalar    hostname returned
  # Example:
  #    my $hostname = $object->getHostAddress( $hostname );
  my $object   = shift;               # Get object
  my $hostname = shift;               # Get hostname to lookup
  my ( $name,                         # Do hostname lookup
       $aliases,
       $addrtype,
       $length,
       @addresses
     ) = gethostbyname( $hostname );
  return( $name );                    # Return hostname
}


sub getHostAliases {
  # This method returns the host aliases.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    scalar    hostname to lookup
  # Result Returned:
  #    scalar    aliases
  # Example:
  #    my $hostname = $object->getHostAddress( $hostname );
  my $object   = shift;               # Get object
  my $hostname = shift;               # Get hostname to lookup
  my ( $name,                         # Do hostname lookup
       $aliases,
       $addrtype,
       $length,
       @addresses ) = gethostbyname( $hostname );
  return( $aliases );                 # Return aliases
}


sub getHostAddress {
  # This method returns the host address
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    scalar    hostname to lookup
  # Result Returned:
  #    scalar
  # Example:
  #    my $address = $object->getHostAddress( $hostname );
  my $object   = shift;                                   # Get object
  my $hostname = shift;                                   # Get hostname to lookup
  my ( $name,                                             # Do hostname lookup
       $aliases,
       $addrtype,
       $length,
       @addresses ) = gethostbyname( $hostname );
  my ( $a, $b, $c, $d ) = unpack( "C4", $addresses[0] );  # Unpack binary format address
  return( "$a.$b.$c.$d" );                                # Construct and return dotted quad
}
