#!/usr/local/bin/perl
#
#   NetSoup::Util::Sort.pm v00.00.01b 12042000
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
#   Description: This Perl 5.0 class provides global methods for the
#                NetSoup Sort classes.
#
#
#   Methods:
#       charsort   -  This private method implements an adaptive character sort
#       localsort  -  This method sorts an array by local character order
#       archsort   -  This method thunks down to localsort()


package NetSoup::Util::Sort;
use strict;
use vars qw( $AUTOLOAD );
use NetSoup::Core;
@NetSoup::Util::Sort::ISA = qw( NetSoup::Core );
1;


sub charsort {
  # This method implements an adaptive character sort.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Left  => $first
  #              Right => $second
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Sort->charsort( First => $first, Second => $second );
  my $Sort   = shift;                                                # Get object
  my %args   = @_;                                                   # Get arguments
  my @left   = split( //, $args{Left} );                             # Get characters of left string
  my @right  = split( //, $args{Right} );                            # Get characters of right string
  my $flag   = 0;                                                    # True indcates sorting required
  my $length = -1;
  @left < @right ? $length += @left : $length += @right;             # Determine longest string
 CMP: for( my $i = 0 ; $i <= $length ; $i++ ) {
    my $left  = ord( $left[$i] );
    my $right = ord( $right[$i] );
    next CMP if( ! exists( $Sort->{Order}->{$left}  ) );
    next CMP if( ! exists( $Sort->{Order}->{$right} ) );
    if( $Sort->{Order}->{$left} > $Sort->{Order}->{$right} ) {       # Sort this time
      $flag++;
      last CMP;
    } elsif( $Sort->{Order}->{$left} < $Sort->{Order}->{$right} ) {  # No sort this time
      last CMP;
    } else {
      ;
    }
  }
  return( $flag );
}


sub localsort {
  # This method sorts an array by local character order.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           Array => \@array
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    $Sort->localsort( Array => \@array );
  my $Sort  = shift;                                                          # Get object
  my %args  = @_;                                                             # Get arguments
  my $array = $args{Array};                                                   # Get array reference
  my $num   = @$array - 2;                                                    # Get number of elements in array
  my $flag  = 0;
 SORT: while( $flag == 0 ) {                                                  # Loop the loop until sorted
    $flag++;
  MEMBERS: for( my $i = 0 ; $i <= $num ; $i++ ) {                             # Iterate over elements
      if( $Sort->charsort( Left  => $array->[$i],                             # Needs sorting?
                           Right => $array->[$i+1] ) != 0 ) {
        ( $array->[$i+1], $array->[$i] ) = ( $array->[$i], $array->[$i+1] );  # Swap elements
        $flag = 0;
      }
    }
  }
  return(1);
}


sub archsort {
  # This method thunks down to localsort().
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           Array => \@array
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    $Sort->archsort( Array => \@array );
  my $Sort = shift;                  # Get object
  return( $Sort->localsort( @_ ) );  # Get down!
}
