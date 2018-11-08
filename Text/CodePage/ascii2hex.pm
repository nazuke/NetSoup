#!/usr/local/bin/perl
#
#   NetSoup::Text::CodePage::ascii2hex.pm v00.00.01a 12042000
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
#       ascii2hex   -  This method encodes ascii strings with hex-encoded characters
#       hex2ascii   -  This method converts hex-encoded strings to plain ascii data


package NetSoup::Text::CodePage::ascii2hex;
use NetSoup::Text::CodePage;
@NetSoup::Text::CodePage::ascii2hex::ISA = qw( NetSoup::Text::CodePage );
1;


sub initialise {
  # This method is the object initialiser.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $object->initialise();
  my $object           = shift;                       # Get object
  $object->{Ascii2Hex} = {};                          # Initialise character set hash reference
  $object->{Hex2ascii} = {};                          # Initialise character set hash reference
  foreach my $key ( 0 .. 255 ) {                      # Iterate over desired ASCII range
    my $char = pack( "C1", $key );                    # Pack value into byte
    my @char = unpack( "H2", $char );                 # Unpack into hex format string
    my $val  = "";                                    # Initialise new hash key
    foreach ( @char ) { $val .= uc( $_ ) }            # Build hash key
    $object->{Ascii2Hex}->{(chr($key))} = $val;       # Insert new key/pair into hash
    $object->{Hex2Ascii}->{$val}        = chr($key);  # Insert new key/pair into hash
  }
  return( $object );
}


sub ascii2hex {
  # This method encodes ascii strings with hex-encoded characters.
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
  #    $object->ascii2hex( Data => \$data );
  my $object = shift;                      # Get object
  my %args   = @_;                         # Get arguments
  my $data   = $args{Data};                # Get unencoded data
  my @chars  = split( //, $$data );        # Split into characters
  $$data     = "";
  foreach my $i ( @chars ) {               # Iterate over raw characters
    $$data .= $object->{Ascii2Hex}->{$i};  # Obtain encoded character from hash
  }
  return(1);
}


sub hex2ascii {
  # This method converts hex-encoded strings to plain ascii data.
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
  #    $object->hex2ascii( Data => \$data );
  my $object = shift;                                   # Get object
  my %args   = @_;                                      # Get arguments
  my $data   = $args{Data};                             # Get unencoded data
  my @chars  = split( //, $$data );                     # Split into characters
  $$data     = "";                                      # Re-initialise scalar
  for( my $i = 0 ; $i <= @chars - 1 ; $i += 2 ) {       # Iterate over hex codes
    my $word = "$chars[$i]$chars[$i+1]";                # Get next hex code
    $$data  .= $object->{Hex2Ascii}->{$word} || $word;  # Obtain encoded character from hash
  }
  return(1);
}
