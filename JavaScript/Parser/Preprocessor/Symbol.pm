#!/usr/local/bin/perl
#
#   NetSoup::JavaScript::Parser::Preprocessor::Symbol.pm v00.00.01a 12042000
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


package NetSoup::JavaScript::Parser::Preprocessor::Symbol;
use strict;
use NetSoup::Core;
@NetSoup::JavaScript::Parser::Preprocessor::Symbol::ISA = qw( NetSoup::Core );
my %TYPES = (
  1 => "KEYWORD",
  1 => "OPERATOR",
  1 => "D_STRING",
  1 => "S_STRING",
  1 => "COMMENT",
  1 => "COMMENT",
  1 => "COMMENT",
);
1;


sub initialise {
  # This method...
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
  my $Symbol       = shift;  # Get object
  my %args         = @_;     # Get arguments
  $Symbol->{Value} = "";
  return(1);
}


sub set {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Value => $value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Symbol       = shift;         # Get object
  my %args         = @_;            # Get arguments
  my $value        = $args{Value};  #
  $Symbol->{Value} = $value;
  return( $Symbol->{Value} );       # Return symbol value
}


sub get {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Symbol = shift;          # Get object
  my %args   = @_;             # Get arguments
  return( $Symbol->{Value} );  # Return symbol value
}


sub append {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Value => $value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Symbol        = shift;         # Get object
  my %args          = @_;            # Get arguments
  my $value         = $args{Value};  #
  $Symbol->{Value} .= $value;
  return( $Symbol->{Value} );        # Return symbol value
}
