#!/usr/local/bin/perl
#
#   NetSoup::String::Protect.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides object methods for protecting and
#                restoring escaped character sequences in strings.
#
#
#   Methods:
#       protect    -  This method protects the escaped characters in a string
#       unprotect  -  This method restores the escaped characters in a string
#       indices    -  This method returns an array of the token keys
#       tokens     -  This method returns an array of the token values
#       BEGIN      -  This method is the class constructor for this class


package NetSoup::String::Protect;
use strict;
use NetSoup::Core;
use NetSoup::Text::Tokenise;
@NetSoup::String::Protect::ISA = qw( NetSoup::Core );
my $Token = NetSoup::Text::Tokenise->new( Token => "PROTECT" );            # Get new Tokenise object
%NetSoup::String::Protect::Sequences = ( "\\0"  => $Token->nextToken(),    # Hash of escape sequence characters
                                         "\\t"  => $Token->nextToken(),
                                         "\\n"  => $Token->nextToken(),
                                         "\\f"  => $Token->nextToken(),
                                         "\\r"  => $Token->nextToken(),
                                         "\\\"" => $Token->nextToken(),
                                         "\\\'" => $Token->nextToken() );
1;


sub protect {
  # This method protects the escaped characters in a string.
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
  #    $object->protect( String => \$string );
  my $object = shift;                                 # Get object
  my %args   = @_;                                    # Get arguments
  my $string = $args{String};                         # Get string reference
  my %hash   = %NetSoup::String::Protect::Sequences;  # Make copy of hash, for readability
  foreach ( keys %hash ) {
    $$string =~ s/\Q$_\E/$hash{$_}/gs;                # Replace escape sequence with token
  }
  return(1);
}


sub unprotect {
  # This method restores the escaped characters in a string.
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
  #    $object->unprotect( String => \$string );
  my $object = shift;                                 # Get object
  my %args   = @_;                                    # Get arguments
  my $string = $args{String};                         # Get string reference
  my %hash   = %NetSoup::String::Protect::Sequences;  # Make copy of hash, for readability
  foreach ( keys %hash ) {
    $$string =~ s/$hash{$_}/$_/gs;                    # Replace tokens with escape sequences
  }
  return(1);
}


sub indices {
  # This method returns an array of the token keys.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $object->indices();
  my $object = shift;                                   # Get object
  my %args   = @_;                                      # Get arguments
  return( keys %NetSoup::String::Protect::Sequences );  # Return hash keys
}


sub tokens {
  # This method returns an array of the token values.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $object->tokens();
  my $object = shift;                                     # Get object
  my %args   = @_;                                        # Get arguments
  return( values %NetSoup::String::Protect::Sequences );  # Return hash values
}
