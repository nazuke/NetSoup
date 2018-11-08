#!/usr/local/bin/perl
#
#   NetSoup::Encoding::Hex.pm v00.00.01a 12042000
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
#       initialise  -  This method is the object initialiser
#       bin2hex     -  This method encodes byte strings as hex-encoded data
#       hex2bin     -  This method converts hex-encoded data to plain byte strings


package NetSoup::Encoding::Hex;
use NetSoup::Core;
@NetSoup::Encoding::Hex::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser.
  # Calls:
  #    none
  # Parameters Required:
  #    Hex
  # Result Returned:
  #    boolean
  # Example:
  #    $Hex->initialise();
  my $Hex         = shift;                       # Get Hex
  $Hex->{Bin2Hex} = {};                          # Initialise character set hash reference
  $Hex->{Hex2Bin} = {};                          # Initialise character set hash reference
  foreach my $key ( 0 .. 255 ) {                 # Iterate over desired ASCII range
    my $char = pack( "C1", $key );               # Pack value into byte
    my @char = unpack( "H2", $char );            # Unpack into hex format string
    my $val  = "";                               # Initialise new hash key
    foreach my $key ( @char ) {                  # Build hash key
      $val .= uc( $key )
    }
    $Hex->{Bin2Hex}->{(chr($key))} = $val;       # Insert new key/pair into hash
    $Hex->{Hex2Bin}->{$val}        = chr($key);  # Insert new key/pair into hash
  }
  return( $Hex );
}


sub bin2hex {
  # This method encodes byte strings as hex-encoded data.
  # Calls:
  #    none
  # Parameters Required:
  #    Hex
  #    hash    {
  #              Data => $Data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Hex->bin2hex( Data => $data );
  my $Hex     = shift;                               # Get Hex
  my %args    = @_;                                  # Get arguments
  my $hexdata = "";                                  # Contains encoded data
  foreach my $char ( split( m//s, $args{Data} ) ) {  # Iterate over raw characters
    $hexdata .= $Hex->{Bin2Hex}->{$char};            # Obtain encoded character from hash
  }
  return( $hexdata );
}


sub hex2bin {
  # This method converts hex-encoded data to plain byte strings.
  # Calls:
  #    none
  # Parameters Required:
  #    Hex
  #    hash    {
  #              Data => $Data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Hex->hex2bin( Data => $Data );
  my $Hex   = shift;                                          # Get Hex
  my %args  = @_;                                             # Get arguments
  my @chars = split( //, $args{Data} );                       # Split into characters
  $bindata  = "";                                             # Contains decoded data
  for( my $i = 0 ; $i < @chars ; $i += 2 ) {                  # Iterate over hex codes
    $bindata .= $Hex->{Hex2Bin}->{"$chars[$i]$chars[$i+1]"};  # Obtain encoded character from hash
  }
  return( $bindata );
}
