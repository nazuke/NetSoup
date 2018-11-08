#!/usr/local/bin/perl
#
#   NetSoup::Util::Arrays.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides object methods for the NetSoup modules.
#                More specifically, this class provides array manipulation methods.
#
#
#   Methods:
#       removeDups  -  This method removes duplicate array entries
#       shuffle     -  This method shuffles the array elements


package NetSoup::Util::Arrays;
use strict;
use NetSoup::Core;
use NetSoup::Maths::Entropy;
use constant CHAOS => NetSoup::Maths::Entropy->new();
@NetSoup::Util::Arrays::ISA = qw( NetSoup::Core );
1;


sub removeDups {
  # This method removes duplicate array entries.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array => \@array
  #              Dups  => \@dups
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Arrays->removeDups( Array => \@array, [ Dups => \@array ] );
  my $Arrays = shift;                                     # Get object
  my %args   = @_;                                        # Get arguments
  my %hash   = ();                                        # Hash will contain one of each array element
  foreach( @{$args{Array}} ) {                            # Load hash with array elements
    if( exists $args{Dups} ) {                            # Check for defined duplicates array reference
      push( @{$args{Dups}}, $_ ) if( exists $hash{$_} );  # Add duplicate to array reference
    }
    $hash{$_} = 1;                                        # Mark element as used
  }
  @{$args{Array}} = ();                                   # Re-initialise array
  foreach( sort keys %hash ) {                            # Reload array with cleaned elements
    push( @{$args{Array}}, $_ );
  }
  return(1);
}


sub shuffle {
  # This method shuffles the array elements into a psuedo-random order.
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
  #    method call
  my $Arrays = shift;                         # Get object
  my %args   = @_;                            # Get arguments
  my %hash   = ();                            # Hash shuffles each array element
 CHAOS: foreach my $element ( @{$args{Array}} ) {   # Load hash with array elements
    my $key     = CHAOS->random( Max => ( time / 3.1415927 ) );
    if( exists $hash{$key} ) {
      redo CHAOS;
    }
    $hash{$key} = $element;
  }
  @{$args{Array}} = ();                       # Re-initialise array
  foreach my $string ( keys %hash ) {         # Peel off strings in hash-order...
    push( @{$args{Array}}, $hash{$string} );  # ...and add to array
  }
  return(1);
}


sub collapse {
  # This method removes duplicates array entries, without re-ordering the array.
  # This is useful for maintaining removing the duplicates from a list
  # where it is important for the list order to be maintained.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array => \@Array
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Arrays = shift;                  # Get object
  my %args   = @_;                     # Get arguments
  my @array  = ();
  my %hash   = ();
  foreach my $i ( @{$args{Array}} ) {
    if( ! exists $hash{$i} ) {
      $hash{$i} = 1;
      push( @array, $i );
    }
  }
  return( @array );
}
