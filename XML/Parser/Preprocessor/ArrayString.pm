#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser::Preprocessor::ArrayString.pm v00.00.01a 12042000
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
#                to fixed length string data. This implementation is
#                enhanced for the NetSoup XML Preprocessor module.
#
#
#   Methods:
#       FETCH  -  This method returns a character from the tied string


package NetSoup::XML::Parser::Preprocessor::ArrayString;
use strict;
use NetSoup::String::ArrayString;
@NetSoup::XML::Parser::Preprocessor::ArrayString::ISA = qw( NetSoup::String::ArrayString );
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
  my $package           = shift;                        # Get package name
  my $class             = ref( $package ) || $package;  # Dereference package into class if necessary
  my $ArrayString       = {};                           # Create empty object as hash reference
  my %args              = @_;                           # Get arguments
  my $data              = $args{Data};                  # Get string reference
  $ArrayString->{Debug} = $args{Debug} || 0;
  $ArrayString->{Data}  = $data;
  $ArrayString->{Size}  = length( $$data );             # Get string length
  $ArrayString->{Error} = 0;
  bless( $ArrayString, $class );                        # Bless object into the $class
  return( $ArrayString );                               # Return blessed object
}


sub FETCH {
  # This method returns a character from the tied string.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    integer
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $ArrayString = shift;                 # Get object
  my $idx         = shift;                 # Get index
  my $data        = $ArrayString->{Data};  #
  my $char        = undef;
  if( $idx <= $ArrayString->{Size} ) {     # Check for valid subscript
    $char = substr( $$data, $idx, 1 );     # Get character in string
  } else {
    $ArrayString->{Error} = 1;
    return( "" );
  }
  return( $char );
}


sub _error {
  # This method returns the object's error flag.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    my $status = $ArrayString->_error();
  my $ArrayString = shift;          # Get object
  return( $ArrayString->{Error} );  # Return error flag
}


sub DESTROY {
  my $ArrayString = shift;     # Get object
  undef $ArrayString->{Data};  # Detach from string data
  undef %{$ArrayString};       # Implode ArrayString object
  return(1);
}
