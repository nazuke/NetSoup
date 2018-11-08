#!/usr/local/bin/perl
#
#   NetSoup::Files::Load.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides object methods for loading file data.
#
#
#   Methods:
#       load  -  This method loads data from a file into a scalar reference


package NetSoup::Files::Load;
use strict;
use integer;
use NetSoup::Files;
@NetSoup::Files::Load::ISA = qw( NetSoup::Files );
1;


sub load {
  # This method loads data from a file into a scalar reference.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Pathname => $pathname
  #              Data     => \$data | \@data
  #              Binary   => 0 | 1
  #              Callback => sub { my $percentage = shift }
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Load     = shift;                        # Get object
  my %args       = @_;                           # Get arguments
  my $data       = $args{Data};                  # Get reference to target scalar
  my $binary     = $args{Binary} || 0;           # Should I use binary mode?
  my $success    = 0;                            # Non-zero indicates success
  my $size       = -s $args{Pathname};
  my $percentage = 0;
  my $ratio      = ( $size / 100 ) if( $size );  # Calculate percentage value
  if( open( LOAD, $args{Pathname} ) ) {          # Check for successful open
    my @buffer = ();
    my $count  = 0;
    binmode( LOAD ) if( $binary );               # Set binary mode for Win32 compatibility
    while( <LOAD> ) {                            # Load file data into reference
      $buffer[$count] = $_;
      $count++;
    }
  SWITCH: for( $data ) {
      m/SCALAR/ && do {
        $$data = join( "", @buffer );            # Assign to scalar reference
        undef @buffer;
        last SWITCH;
      };
      m/ARRAY/ && do {
        @$data = @buffer;                        # Attach array reference to buffer
        last SWITCH;
      };
      m// && do {
        $Load->debug( "ERROR" );
      };
    }
    close( LOAD );
    $success++;
  }
  return( $success );
}


sub immediate {
  # This method loads data from a file and returns it as a scalar.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Pathname => $pathname
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Load     = shift;                      # Get object
  my %args     = @_;                         # Get arguments
  my $pathname = $args{Pathname};
  my $data     = "";
  $Load->load( Pathname => $args{Pathname},  #
               Data     => \$data ) || return( undef );
  return( $data );
}


sub load_hash {
  # This method loads a tab-delimited text file into a hash.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Pathname => $pathname
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Load     = shift;
  my %args     = @_;
  my $pathname = $args{Pathname};
  my $data     = $Load->immediate( Pathname => $args{Pathname} );
  my %hash     = ();
  foreach my $line ( split( m/[\r\n]/, $data ) ) {
    chomp $line;
    my ( $key, $value ) = split( m/\t/, $line );
    $hash{$key} = $value;
  }
  return( %hash );
}
