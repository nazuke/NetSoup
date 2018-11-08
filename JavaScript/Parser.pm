#!/usr/local/bin/perl
#
#   NetSoup::JavaScript::Parser.pm v00.00.01a 12042000
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


package NetSoup::JavaScript::Parser;
use strict;
use NetSoup::Core;
use NetSoup::JavaScript::Parser::Preprocessor;
use NetSoup::JavaScript::Parser::Compiler;
@NetSoup::JavaScript::Parser::ISA = qw( NetSoup::Core );
my $PREPROCESSOR = "NetSoup::JavaScript::Parser::Preprocessor";
my $COMPILER     = "NetSoup::JavaScript::Parser::Compiler";
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
  my $Parser = shift;  # Get object
  my %args   = @_;     # Get arguments
  return( $Parser );
}


sub parser {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Script => \$script
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Parser->parser( Script => \$script );
  my $Parser       = shift;                                 # Get object
  my %args         = @_;                                    # Get arguments
  my $Preprocessor = $PREPROCESSOR->new();                  #
  my $Compiler     = $COMPILER->new();
  my $Script       = $args{Script};                         # Get scalar reference of script text
  $Parser->_normalize( Script => $Script );


  if( $Preprocessor->preprocessor( Script => $Script ) ) {  # Preprocess into symbol table
    ;
  } else {
    ;
  }


  return(1);
}


sub _normalize {
  # This private method prepares the raw XML data before parsing.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Script => \$script
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Parser->_normalize( Script => \$script );
  my $Parser = shift;                  # Get object
  my %args   = @_;                     # Get arguments
  my $Script = $args{Script};          #
  $$Script   =~ s/[\x0D\x0A]/\x0A/gs;  # Normalize line endings to \x0A (newline)
  return(1);
}
