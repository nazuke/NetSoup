#!/usr/local/bin/perl
#
#   NetSoup::Util::Sort::Length.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides object methods for sorting
#                arrays by the length of their string values.
#
#
#   Methods:
#       sort  -  This method sorts an array by string length


package NetSoup::Util::Sort::Length;
use strict;
use integer;
use NetSoup::Core;
@NetSoup::Util::Sort::Length::ISA = qw( NetSoup::Core );
1;


sub sort {
  # This method sorts an array by string length.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array => \@array
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Length->sort( Array => \@array );
  my $Length = shift;                                           # Get object
  my %args   = @_;                                              # Get arguments
  my $array  = $args{Array};                                    # Get array reference
  my $num    = @$array - 1;                                     # Get number of elements in array
  my $i      = 0;                                               # Counter
 SORT: for( $i = 0 ; $i <= $num ; $i++ ) {                      # Iterate over elements
    my ( $first, $second ) = ( $array->[$i], $array->[$i+1] );  # Get copies of strings
    if( length( $second ) > length( $first ) ) {                # Compare element lengths
      ( $array->[$i+1], $array->[$i] ) = ( $first, $second );   # Swap elements
      $Length->sort( Array => $array );                         # Recurse
    }
  }
  return(1);
}


sub sort2 {
  # This method sorts an array by string length.
  # This is the non-recursive version of the sort() method.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array => \@array
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Length->sort2( Array => \@array );
  my $Length = shift;                                           # Get object
  my %args   = @_;                                              # Get arguments
  my $array  = $args{Array};                                    # Get array reference
  my $num    = @$array - 1;                                     # Get number of elements in array
  my $i      = 0;                                               # Counter
 SORT: for( $i = 0 ; $i <= $num ; $i++ ) {                      # Iterate over elements
    my ( $first, $second ) = ( $array->[$i], $array->[$i+1] );  # Get copies of strings
    if( length( $second ) > length( $first ) ) {                # Compare element lengths
      ( $array->[$i+1], $array->[$i] ) = ( $first, $second );   # Swap elements
      goto SORT;
    }
  }
  return(1);
}


sub sort3 {
  # This method sorts an array by string length.
  # Theoretically, this should be more efficient
  # than the sort2() method.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array => \@array
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Length->sort3( Array => \@array );
  my $Length = shift;                                             # Get object
  my %args   = @_;                                                # Get arguments
  my $array  = $args{Array};                                      # Get array reference
  my $stop   = 1;
  while( $stop != 0 ) {
    my $sort = 0;
    for( my $i = 0 ; $i <= ( @{$array} - 1 ) ; $i++ ) {           # Iterate over elements
      my ( $first, $second ) = ( $array->[$i], $array->[$i+1] );  # Get copies of strings
      if( length( $second ) > length( $first ) ) {                # Compare element lengths
        ( $array->[$i+1], $array->[$i] ) = ( $first, $second );   # Swap elements
        $sort++;
      }
    }
    $stop = $sort;
  }
  return(1);
}


sub sort4 {
  # This method sorts an array by string length.
  # Theoretically, this should be the most efficient.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array  => \@Array
  #              Target => \@Target
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Length->sort4( Array => \@array, Target => \@Target );
  my $Length = shift;                                           # Get object
  my %args   = @_;                                              # Get arguments
  my $Array  = $args{Array};                                    # Get array reference
  my $Target = $args{Target};                                   # Get target array reference
  my @Sorted = ();
  for( my $i = 0 ; $i <= ( @{$Array} - 1 ) ; $i++ ) {
    my $length       = length( $Array->[$i] );
    $Sorted[$length] = [] if( ! defined $Sorted[$length] );
    push( @{$Sorted[$length]}, $Array->[$i] );
  }
  for( my $i = ( @Sorted - 1 ) ; $i >= 0  ; $i-- ) {
    if( defined $Sorted[$i] ) {
      @{$Sorted[$i]} = sort( @{$Sorted[$i]} );
      for( my $j = 0 ; $j <= ( @{$Sorted[$i]} - 1 ) ; $j++ ) {  #
        if( defined $Sorted[$i]->[$j] ) {
          push( @{$Target}, $Sorted[$i]->[$j] );                # Copy result into target array
        }
      }
    }
  }
  return(1);
}
