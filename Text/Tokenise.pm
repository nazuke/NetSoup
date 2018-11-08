#!/usr/local/bin/perl
#
#   NetSoup::Text::Tokenise.pm v00.00.01b 12042000
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
#   Description: This Perl 5.0 class generates consistent unique serial tokens.
#
#
#   Methods:
#       initialise   -  This method is the object initialiser for this class.
#       initToken    -  This method initialises the token counter
#       tokenStart   -  This method returns the value of the initial token value
#       tokenValue   -  This method returns the value of the current token value
#       nextToken    -  This method creates a new reference token into the data
#       formatToken  -  This method formats a token value


package NetSoup::Text::Tokenise;
use strict;
use NetSoup::Core;
@NetSoup::Text::Tokenise::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    initToken()
  # Parameters Required:
  #    object
  #    hash    {
  #              Token => $token
  #            }
  # Result Returned:
  #    object
  # Example:
  #    $object->initialise( [ Token => $token ] );
  my $object        = shift;                                       # Get object
  my %args          = @_;                                          # Get arguments
  my $token         = $args{Token} || undef;                       # Get initial token value
  $object->{Length} = 10;                                          # Length of token counter
  if( defined $token ) {
    $object->{Base}  = $token;                                     # Initialise base token string
    $object->{Count} = 0 x $object->{Length};                      # Initialise current token counter to zero
  } else {
    $object->{Base}  = $object->initToken();                       # Initialise base token string
    $object->{Count} = 0 x $object->{Length};                      # Initialise current token counter to zero
    $object->{Token} = $object->{Base} . "::" . $object->{Count};  # Initialise current token to null string
    $object->{Start} = $object->{Token};                           # Store initial token
  }
  return(1);
}


sub initToken {
  # This method initialises the token counter.
  # Calls:
  #    none
  # Parameters Required:
  #    none
  # Result Returned:
  #    scalar   new token
  # Example:
  #    my $value = $object->initToken();
  my $object = shift;                                                                   # Get object
  my( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);  # Get current time
  return( join( "", ( $sec, $min, $hour, $mday, $mon, $year ) ) );                      # Build time string
}


sub tokenStart {
  # This method returns the value of the initial token value.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar    next token
  # Example:
  #    $object->tokenStart();
  my $object = shift;          # Get object
  return( $object->{Start} );  # Return start token value
}


sub tokenValue {
  # This method returns the value of the current token value.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar    next token
  # Example:
  #    $object->tokenValue();
  my $object = shift;          # Get object
  return( $object->{Token} );  # Return current token value
}


sub nextToken {
  # This method creates a new reference token into the document.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar    next token
  # Example:
  #    $object->nextToken();
  my $object       = shift;                                    # Get object
  $object->{Token} = $object->{Base} .
    "::" . $object->formatToken( Token => $object->{Count} );  # Build new token string
  $object->{Count}++;                                          # Increment token counter
  $object->{Token} = $object->{Token};
  return( "!!" . $object->{Token} . "!!" );
}


sub formatToken {
  # This method formats a token value.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar    next token
  # Example:
  #    $object->formatToken();
  my $object = shift;                                            # Get object
  my %args   = @_;                                               # Get arguments
  my $token  = $args{Token};                                     # Get token to format
  my $length = $object->{Length};                                # Get token length
  $token     = ( 0 x ( $length - length( $token ) ) ) . $token;  # Format token
  return( $token );
}
