#!/usr/local/bin/perl
#
#   NetSoup::String::ArrayString.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class provides array-style accesses
#                to fixed length string data.
#
#
#   Methods:
#       method  -  description


package NetSoup::String::ArrayString;
use strict;
use NetSoup::Core;
@NetSoup::String::ArrayString::ISA = qw( NetSoup::Core );
1;


sub TIEARRAY {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => \$data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $package          = shift;                        # Get package name
  my $class            = ref( $package ) || $package;  # Dereference package into class if necessary
  my $ArrayString      = {};                           # Create empty object as hash reference
  my %args             = @_;                           # Get arguments
  my $data             = $args{Data};                  # Get string reference
  $ArrayString->{Data} = $data;
  $ArrayString->{Size} = length( $$data );             # Get string length
  bless( $ArrayString, $class );                       # Bless object into the $class
  return( $ArrayString );                              # Return blessed object
}


sub FETCH {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    integer
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $ArrayString = shift;                      # Get object
  my $idx         = shift;                      # Get index
  my $data        = $ArrayString->{Data};
  my $char        = substr( $$data, $idx, 1 );  # Get character in string
  return( $char );
}


sub STORE {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $ArrayString = shift;  # Get object
  my %args        = @_;     # Get arguments

  return(1);
}


sub FETCHSIZE {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $ArrayString = shift;                 # Get object
  my $size        = $ArrayString->{Size};  # String length
  return( $size );
}


sub STORESIZE {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $ArrayString = shift;  # Get object
  my %args        = @_;     # Get arguments
  return(1);
}


sub DESTROY {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $ArrayString      = shift;
  $ArrayString->{Data} = undef;
  return(1);
}
