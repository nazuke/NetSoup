#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser::Preprocessor::QuoteStack.pm v00.00.01a 12042000
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
#                enhanced the NetSoup XML Preprocessor module.
#
#
#   Methods:
#       method  -  description


package NetSoup::XML::Parser::Preprocessor::QuoteStack;
use strict;
use NetSoup::Core;
@NetSoup::XML::Parser::Preprocessor::QuoteStack::ISA = qw( NetSoup::Core );
my $MODULE = "QuoteStack";
my %ERRORS = ();
while( <NetSoup::XML::Parser::Preprocessor::QuoteStack::DATA> ) {
  chomp;
  last if( ! length );
  my( $key, $value ) = split( /\t+/ );
  $ERRORS{$key}      = $value;
}
1;


sub TIESCALAR {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Stack => \@stack
  #              Ref   => \$ref
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $package          = shift;                        # Get package name
  my $class            = ref( $package ) || $package;  # Dereference package into class if necessary
  my $QuoteStack       = {};                           # Create empty object as hash reference
  my %args             = @_;                           # Get arguments
  $QuoteStack->{Value} = 0;                            # Set initial value
  $QuoteStack->{Stack} = $args{Stack};                 # Get stack reference
  $QuoteStack->{Count} = $args{Count};                 # Get count reference
  $QuoteStack->{Ref}   = $args{Ref};                   # Set reference to watch
  bless( $QuoteStack, $class );                        # Bless object into the $class
  return( $QuoteStack );                               # Return blessed object
}


sub FETCH {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $QuoteStack = shift;          # Get package name
  return( $QuoteStack->{Value} );  # Return blessed object
}


sub STORE {
  # This method
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    $value
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $QuoteStack = shift;                    # Get package name
  my $value      = shift;
  my $ref        = $QuoteStack->{Ref};
  if( $value == 1 ) {
    push( @{$QuoteStack->{Stack}}, $$ref );  #
    $QuoteStack->{Count}++;
  } else {
    $QuoteStack->{Count}--;
  }
  $QuoteStack->{Value} = $value;
  return( $QuoteStack->{Value} );
}


__DATA__
0001  Missing closing double quote near __
