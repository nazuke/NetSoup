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
#   Description: This Perl 5.0 class provides object methods for
#                sending chunks of data to a socket.
#
#
#   Methods:
#       method  -  description


package NetSoup::Protocol::BatchUp;
use strict;
use NetSoup::Core;
use NetSoup::Protocol;
@NetSoup::Protocol::BatchUp::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    BatchUp
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $BatchUp                  = shift;            # Get BatchUp object
  my %args                     = @_;               # Get arguments
  $BatchUp->{Hostname}         = $args{Hostname};  #
  $BatchUp->{Port}             = $args{Port};      #
  $BatchUp->{QLength}          = $args{QLength};   #
  $BatchUp->{Prefix}           = $args{Prefix};    # Data to be prefixed to start of each run
  $BatchUp->{Postfix}          = $args{Postfix};   # Data to be appended to end of each run
  $BatchUp->{State}->{Counter} = 0;
  $BatchUp->{State}->{Buffer}  = "";
  return( $BatchUp );
}


sub add {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    BatchUp
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $BatchUp                  = shift;               # Get BatchUp object
  my %args                     = @_;                  # Get arguments
  $BatchUp->{State}->{Buffer} .= $args{Data};
  $BatchUp->{State}->{Counter}++;
  if( $BatchUp->{State}->{Counter} == $BatchUp->{QLength} ) {
    $BatchUp->transmit();
  }
  return(1);
}


sub transmit {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    BatchUp
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $BatchUp  = shift;               # Get BatchUp object
  my %args     = @_;                  # Get arguments
  my $response = "";
  my $Protocol = NetSoup::Protocol->new( Address => $BatchUp->{Hostname},
                                         Port    => $BatchUp->{Port} );
  if( $Protocol->client() ) {
    my $buffer = join( "",
                       $BatchUp->{Prefix},
                       $BatchUp->{State}->{Buffer},
                       $BatchUp->{Postfix} );
    $Protocol->put( Data => \$buffer );
    $BatchUp->flush();
  } else {
    return( undef );
  }
  return( $response );
}


sub flush {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    BatchUp
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $BatchUp                  = shift; # Get BatchUp object
  my %args                     = @_;    # Get arguments
  $BatchUp->{State}->{Counter} = 0;     # Reset counter
  $BatchUp->{State}->{Buffer}  = "";    # Clear buffer
  return(1);
}


sub DESTROY {
  my $BatchUp = shift; # Get BatchUp object
  if( length( $BatchUp->{State}->{Buffer} ) > 0 ) {
    $BatchUp->transmit();
  }
  return(1);
}
