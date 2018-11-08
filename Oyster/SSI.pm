#!/usr/local/bin/perl
#
#   NetSoup::class.pm v00.00.01a 12042000
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


package NetSoup::Oyster::SSI;
use strict;
use POSIX qw( strftime );
use NetSoup::Core;
use NetSoup::Files::Load;
@NetSoup::Oyster::SSI::ISA = qw( NetSoup::Core );
use constant LOGTIME => strftime( "%a %b %e %H:%M:%S %Y", gmtime );
1;


sub initialise {
  # This method is the object initialiser for this class.
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
  my $SSI  = shift;  # Get SSI object
  my %args = @_;     # Get arguments
  return(1);
}


sub execute {
  # This method executes the SSI directives in a chunk of HTML.
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
  my $SSI  = shift;                                                                          # Get SSI object
  my %args = @_;                                                                             # Get arguments
  my $HTML = $args{HTML};                                                                    # Get copy of HTML to process
  my $Load = NetSoup::Files::Load->new();                                                    # Get new Load object
  while( $HTML =~ m/(<!--\#include virtual=\"([^\"]+)\"-->)/gs ) {                               # This will attempt to replace recursively
    my ( $pattern, $pathname ) = ( $1, $2 );
    my $Text                   = "";
    if( exists $ENV{REDIRECT_DOCUMENT_URI} ) {
      if( $pathname =~ m/^\// ) {
        $pathname = "$ENV{REDIRECT_DOCUMENT_ROOT}$pathname";
      } else {
        $pathname = $Load->pathname( Pathname => "$ENV{REDIRECT_DOCUMENT_ROOT}$ENV{REDIRECT_DOCUMENT_URI}" ) . $pathname;
      }
    } else {
      if( $pathname =~ m/^\// ) {
        $pathname = "$ENV{DOCUMENT_ROOT}" . $pathname;
      } else {
        $pathname = $Load->pathname( Pathname => "$ENV{DOCUMENT_ROOT}$ENV{DOCUMENT_URI}" ) . $pathname;
      }
    }
    if( -e $pathname ) {
      $Load->load( Pathname => $pathname, Data => \$Text );                                  # Load target file
      $HTML =~ s/\Q$pattern\E/$Text/gs;
    } else {
      print( STDERR LOGTIME . qq( ERROR: Could include file "$pathname"\n) );
    }
  }
  return( $HTML );                                                                           # Return processed HTML
}
