#!/usr/local/bin/perl
#
#   NetSoup::Core::GC.pm v01.00.01g 12042000
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
#                This class does not do much by itself, it is intended that most of
#                the other classes inherit from this class.
#
#
# Methods:
#    new             -  This method is the object constructor for this class


package NetSoup::Core::GC;
use strict;
use NetSoup::Core;
@NetSoup::Core::GC::ISA = qw( NetSoup::Core );
1;


sub destroy {
  # This method is the object destructor for this class.
  return;
  my $Object = shift;
  my %loop   = ();
  foreach my $property ( keys %{$Object} ) {
    print( "Destroying: $Object->{$property}\n" );
    next if( exists $loop{$Object->{$property}} );
  TYPE: for( $Object->{$property} ) {
      m/ARRAY/ && do {
        $Object->destroyArray( Array => $Object->{$property},
                               Loop  => \%loop,
                               Depth => 1 );
        last TYPE;
      };
      m/HASH/ && do {
        $Object->destroyHash( Hash  => $Object->{$property},
                              Loop  => \%loop,
                              Depth => 1 );
        last TYPE;
      };
    }
    #$loop{$Object->{$property}} = 1;
    delete $Object->{$property};
  }
  return(1);
}


sub destroyArray {
  my $Object = shift;
  my %args   = @_;
  my $Array  = $args{Array};
  my $Loop   = $args{Loop};
  my $Depth  = $args{Depth};
  print( "\t" x $args{Depth} . "Destroying Array: $Array\n" );
  for( my $i = 0 ; $i <= ( @{$Array} - 1 ) ; $i++ ) {
    next if( ! defined $Array->[$i] );
    next if( ! defined $Loop->{$Array->[$i]} );
  TYPE: for( $Array->[$i] ) {
      last TYPE if( ! defined );
      m/ARRAY/ && do {
        $Object->destroyArray( Array => $Array->[$i],
                               Loop  => $args{Loop},
                               Depth => $args{Depth} + 1 );
        last TYPE;
      };
      m/HASH/ && do {
        $Object->destroyHash( Hash  => $Array->[$i],
                              Loop  => $args{Loop},
                              Depth => $args{Depth} + 1 );
        last TYPE;
      };
    }
    $Loop->{$Array->[$i]} = 1;
    undef $Array->[$i];
  }
  return(1);
}


sub destroyHash {
  my $Object = shift;
  my %args   = @_;
  my $Hash   = $args{Hash};
  my $Loop   = $args{Loop};
  my $Depth  = $args{Depth};
  print( "\t" x $args{Depth} . "Destroying Hash: $Hash\n" );
  foreach my $key ( keys %{$Hash} ) {
    next if( ! defined $Hash->{$key} );
    next if( ! defined $Loop->{$Hash->{$key}} );
  TYPE: for( $Hash->{$key} ) {
      last TYPE if( ! defined );
      m/ARRAY/ && do {
        $Object->destroyArray( Array => $Hash->{$key},
                               Loop  => $args{Loop},
                               Depth => $args{Depth} + 1 );
        last TYPE;
      };
      m/HASH/ && do {
        $Object->destroyHash( Hash  => $Hash->{$key},
                              Loop  => $args{Loop},
                              Depth => $args{Depth} + 1 );
        last TYPE;
      };
    }
    $Loop->{$Hash->{$key}} = 1;
    delete $Hash->{$key};
  }
  return(1);
}
