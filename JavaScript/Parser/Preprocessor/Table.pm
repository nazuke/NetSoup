#!/usr/local/bin/perl
#
#   NetSoup::JavaScript::Parser::Preprocessor::Table.pm v00.00.01a 12042000
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


package NetSoup::JavaScript::Parser::Preprocessor::Table;
use strict;
use NetSoup::Core;
@NetSoup::JavaScript::Parser::Preprocessor::Table::ISA = qw( NetSoup::Core );
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
  my $Table      = shift;  # Get object
  my %args       = @_;     # Get arguments
  $Table->{List} = [];     # List of symbol objects
  return(1);
}


sub add {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Symbol => $Symbol
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Table  = shift;                   # Get object
  my %args   = @_;                      # Get arguments
  my $Symbol = $args{Symbol};
  push ( @{$Table->{List}}, $Symbol );  # Add symbol to table
  return(1);
}


sub dumper {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Symbol => $Symbol
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Table = shift;                   # Get object
  my %args  = @_;                      # Get arguments
  foreach my $symbol ( @{$Table->{List}} ) {
    ;
  }
  return(1);
}
