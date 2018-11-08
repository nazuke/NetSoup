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


package NetSoup::Encoding::Base64;
use strict;
use NetSoup::Core;
@NetSoup::Encoding::Base64::ISA = qw( NetSoup::Core );
%NetSoup::Encoding::Base64      = ( "0"  => "A",
                                    "1"  => "B",
                                    "2"  => "C",
                                    "3"  => "D",
                                    "4"  => "E",
                                    "5"  => "F",
                                    "6"  => "G",
                                    "7"  => "H",
                                    "8"  => "I",
                                    "9"  => "J",
                                    "10" => "K",
                                    "11" => "L",
                                    "12" => "M",
                                    "13" => "N",
                                    "14" => "O",
                                    "15" => "P",
                                    "16" => "Q",
                                    "17" => "R",
                                    "18" => "S",
                                    "19" => "T",
                                    "20" => "U",
                                    "21" => "V",
                                    "22" => "W",
                                    "23" => "X",
                                    "24" => "Y",
                                    "25" => "Z",
                                    "26" => "a",
                                    "27" => "b",
                                    "28" => "c",
                                    "29" => "d",
                                    "30" => "e",
                                    "31" => "f",
                                    "32" => "g",
                                    "33" => "h",
                                    "34" => "i",
                                    "35" => "j",
                                    "36" => "k",
                                    "37" => "l",
                                    "38" => "m",
                                    "39" => "n",
                                    "40" => "o",
                                    "41" => "p",
                                    "42" => "q",
                                    "43" => "r",
                                    "44" => "s",
                                    "45" => "t",
                                    "46" => "u",
                                    "47" => "v",
                                    "48" => "w",
                                    "49" => "x",
                                    "50" => "y",
                                    "51" => "z",
                                    "52" => "0",
                                    "53" => "1",
                                    "54" => "2",
                                    "55" => "3",
                                    "56" => "4",
                                    "57" => "5",
                                    "58" => "6",
                                    "59" => "7",
                                    "60" => "8",
                                    "61" => "9",
                                    "62" => "+",
                                    "63" => "/",
                                    "PD" => "=" );
1;


sub bin2base64 {
  # Description.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => $data
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    $Base64->bin2base64( Data => $data );
  my $Base64 = shift;                                                               # Get Base64 object
  my %args   = @_;                                                                  # Get arguments
  my $data   = $args{Data};                                                         # Get data to encode
  my $output = "";                                                                  # Will contain encoded data
 DO: while( $data ) {
    my ( $triplet ) = ( $data =~ m/^(..?.?)/s );                                    # Yield triplet of bytes from input string
    my $addPadding  = 3 - length( $triplet );                                       # Calcuate underflow of bytes
    if ( $triplet ) {                                                               # Check for data
      $data      =~ s/^\Q$triplet//sx;                                              # Strip triplet from input string
      my $bitmap = unpack( "B*", $triplet );                                        # Unpack into bit representation
      $bitmap   .= "0" x ( 24 - length( $bitmap ) ) if( length( $bitmap ) != 24 );  # Add trailing padding
      my @quad   = ( $bitmap =~ m/(.{6})?(.{6})?(.{6})?(.{6})?/ );                  # Extract four six-bit strings
      for ( my $i = 0 ; $i <= 3 - $addPadding ; $i++ ) {
        my $byte = "00" . $quad[$i];                                                # Pad with leading zeros
        $byte    = pack( "B*", $byte );                                             # Pack bits into a byte
        $output .= $NetSoup::Encoding::Base64{ord($byte)};                          # Look up value in hash table
      }
      $output .= $NetSoup::Encoding::Base64{PD} x $addPadding;                      # Add special trailing padding characters
    } else {
      last DO;                                                                      # Exit loop on no more input
    }
  }
  return( $output );                                                                # Return encoded data
}
