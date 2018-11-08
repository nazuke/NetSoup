#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers.pm v00.00.01a 12042000
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


package NetSoup::XHTML::MenuMaker::Drivers;
use strict;
use NetSoup::Core;
@NetSoup::XHTML::MenuMaker::Drivers::ISA = qw( NetSoup::Core );
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
  my $Drivers     = shift;  # Get Drivers object
  my %args        = @_;     # Get arguments
  $Drivers->{ID}  = 0;      # Stores a hash of unique id values
  $Drivers->{IDS} = [];     # Array of ID's generated
  return( $Drivers );
}


sub uniqid {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Drivers = shift;                   # Get Drivers object
  my %args    = @_;                      # Get arguments
  my $String  = $args{String} || "MM";
  $String     =~ s/[ \r\n]+/_/gis;       # Clean white space
  $Drivers->{ID}++;
  push( @{$Drivers->{IDS}}, $String . $Drivers->{ID} ); 
  return( $String . $Drivers->{ID} );  # Return ID string and increment ID counter
}


sub listids {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Drivers = shift;           # Get Drivers object
  my %args    = @_;              # Get arguments
  return( @{$Drivers->{IDS}} );  # Return array of ID's
}
