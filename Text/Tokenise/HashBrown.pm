#!/usr/local/bin/perl
#
#   NetSoup::Text::Tokenise::HashBrown.pm v00.00.01a 12042000
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
#       intialise  -  This method is the object initialiser for this class
#       hash       -  This method adds a key value pair to the object
#       unhash     -  This method returns the decoded key value


package NetSoup::Text::Tokenise::HashBrown;
use strict;
use NetSoup::Core;
@NetSoup::Text::Tokenise::HashBrown::ISA = qw( NetSoup::Core );
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
  my $object       = shift;               # Get object
  my %args         = @_;                  # Get arguments
  $object->{Table} = { Hashed   => {},    # Stores the key/value pairs
                       Unhashed => {} };
  return(1);
}


sub hash {
  # This method adds a key value pair to the object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              String => \$string
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                                 # Get object
  my %args   = @_;                                    # Get arguments
  my $string = $args{String};                         # Get string reference
  my $data   = unpack( "H*", $$string );              # Unpack into hex format
  $object->{Table}->{Hashed}->{$data}    = $$string;
  $object->{Table}->{Hashed}->{$$string} = $data;
  return( $data );
}


sub unhash {
  # This method returns the decoded key value.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              String => \$string
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                   # Get object
  my %args   = @_;                      # Get arguments
  my $string = $args{String};           # Get string reference
  my $data   = pack( "H*", $$string );  # Unpack into hex format
  return( $data );
}
