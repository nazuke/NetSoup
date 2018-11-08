#!/usr/local/bin/perl
#
#   NetSoup::Protocol::GTP.pm v00.00.01a 12042000
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


package NetSoup::Protocol::GTP;
use strict;
use NetSoup::Protocol;
@NetSoup::Protocol::GTP::ISA = qw( NetSoup::Protocol );
1;


sub initialise {
  # Description.
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
  my $object         = shift;  # Get object
  my %args           = @_;     # Get arguments
  $object->{Raw}     = "";     # Initialise raw data member
  $object->{Header}  = {};     # Initialise header members
  $object->{Strings} = [];     # Strings array used by Server
  $object->{Pairs}   = {};     # Pairs hash used by Client
  return(1);
}


sub parseMessage {
  # This method composes and sends a reply to the client.
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
  my $object            = shift;                                # Get object
  my %args              = @_;                                   # Get arguments
  my $data              = $args{Data};
  my @req               = split( /\x0D\x0A/gs, $$data );        # Split on line endings
  my $body              = 0;                                    # True indicates parsing strings
  @{$object->{Strings}} = ();                                   # Re-initialise strings member
 PARSE: foreach my $line ( @req ) {                             # Parse client data
    $body = 1 if( $line =~ m/^$/gs );                           # Look for header terminator
  SWITCH: for( $body ) {
      m/0/ && do {
        my ( $key, $value )       = split( /:[ \t]*/, $line );  # Split into key/value pair
        $object->{Header}->{$key} = $value;
        last SWITCH;
      };
      m/1/ && do {
        last SWITCH if( length( $line ) <= 0 );
        my ( $source, $target ) = split( /\t/, $line );         # Split into components
        push( @{$object->{Strings}}, [ $source, $target ] );    # Add string componentes to object
        last SWITCH;
      };
    }
  }
  return(1);
}


sub parseBody {
  # This method composes and sends a reply to the client.
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
  my $object          = shift;                           # Get object
  my %args            = @_;                              # Get arguments
  my $data            = $args{Data};
  my @req             = split( /\x0D\x0A/gs, $$data );   # Split on line endings
  %{$object->{Pairs}} = ();                              # Re-initialise strings hash
 PARSE: foreach my $line ( @req ) {                      # Parse client data
    last SWITCH if( length( $line ) <= 0 );
    my ( $source, $target )     = split( /\t/, $line );  # Split into components
    $object->{Pairs}->{$source} = $target;               # Add string components to object
  }
  return(1);
}
