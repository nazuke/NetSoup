#!/usr/local/bin/perl
#
#   NetSoup::Util::Hashes.pm v00.00.01a 12042000
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
#       string2Key  -  This method generates a unique hash key given a string


package NetSoup::Util::Hashes;
use strict;
use integer;
use NetSoup::Core;
@NetSoup::Util::Hashes::ISA = qw( NetSoup::Core );
1;


sub newString2Key {
  # This method generates a unique hash key given a string.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #          Hash   => \%hash
  #          Length => $length
  #          String => \$string
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object  = shift;                                                               # Get object
  my %args    = @_;                                                                  # Get arguments
  my $hash    = $args{Hash};                                                         # Get hash reference
  my $length  = $args{Length} || 4;                                                  # Get required length of hash key
  my $string  = $args{String};                                                       # Get hash string value
  my $copy    = uc( $$string );                                                      # Make private copy of string
  my $key     = "";                                                                  # Initialise key container
  
  
  my @words   = split( /\s/, $copy );
  
  
  
  #  my $freq    = int( $length / @words - 1 ) || 1;                                    # Calculate number of character to take from each word
  my $freq    = @words - 1 || 1;                                    # Calculate number of character to take from each word
  #  $object->debug( $freq );# DEBUG
  my $regex   = "";                                                                  # Initialise regular expression container
  foreach ( @words ) {                                                               # Build up regular expression
    $regex .= '(\w{'.$freq.'})[^\s]*\s*';
  }
  
  $object->debug( $regex );# DEBUG
  
  my @chars = ( $copy =~ m/^$regex/ );                                            # Get characters from each word
  for( my $i = 0 ; $i <= $length - 1 ; $i++ ) {                                      # Build key from stored characters
    #    $key .= $chars[$i];
  }
  #  $object->debug( $key );
  
  
  return("");# DEBUG
  
  
  
  if( exists( $$hash{$key} ) ) {                                                     # Check for existing key
    $copy    =~ s/[\x00-\x2F\x3A-\x40\x5B-\x60\x7B-\xFF]+//gs;                     # Remove illegal characters
    ( $key ) = ( $copy =~ m/^(.{1,\Q$length\E})/ );                                # Compute initial key value
    $key    .= ( "_" x ( $length - length $key ) ) if( length $key < $length );    # Fix key underrun
  }
  
  
  if( exists( $$hash{$key} ) ) {                                                     # Check for existing key
    my $char = $length - 1;
  TRY_DIGITS: while( $char >= 0 ) {                                                # Try changing characters to numbers
      my @chars = split( //, $key );
    DIGITS: for( my $i = 0 ; $i <= 9 ; $i++ ) {                                  # Counting down...
        $chars[$char] = $i;
        $key          = join( "", @chars );
        last TRY_DIGITS if( ! exists( $$hash{$key} ) );                        # Bail out on good key
      }
      $char--;                                                                   # Go to previous character in key
    }
  }
  
  
  if( exists( $$hash{$key} ) && $key == 9999 ) {                                     # Check for existing key
    my $max = "9" x $length;
  NUMERIC: for( my $i = 0 ; $i <= $max ; $i++ ) {
      $key = ( "0" x ( $length - length( $i ) ) ) . $i;                          # Construct new numeric key
      last NUMERIC if( ! exists( $$hash{$key} ) );                               # Bail out on good key
    }
  }
  
  
  $object->debug( "ERROR\t$key" ) if( exists( $$hash{$key} ) );                      # DEBUG
  return( $key );                                                                    # Return computed key value
}








sub string2Key {
  # This method generates a unique hash key given a string.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #          Hash   => \%hash
  #          Length => $length
  #          String => \$string
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object  = shift;                                                              # Get object
  my %args    = @_;                                                                 # Get arguments
  my $hash    = $args{Hash};                                                        # Get hash reference
  my $length  = $args{Length} || 4;                                                 # Get required length of hash key
  my $string  = $args{String};                                                      # Get hash string value
  my $copy    = uc( $$string );                                                     # Make private copy of string
  $copy       =~ s/[\x00-\x2F\x3A-\x40\x5B-\x60\x7B-\xFF]+//gs;                     # Remove illegal characters
  my ( $key ) = ( $copy =~ m/^(.{1,\Q$length\E})/ );                                # Compute initial key value
  $key       .= ( "_" x ( $length - length $key ) ) if( length $key < $length );    # Fix key underrun
  if( exists( $$hash{$key} ) ) {                                                    # Check for existing key
    my $char = $length - 1;
  TRY_DIGITS: while( $char >= 0 ) {                                             # Try changing characters to numbers
      my @chars = split( //, $key );
    DIGITS: for( my $i = 0 ; $i <= 9 ; $i++ ) {
        $chars[$char] = $i;
        $key = join( "", @chars );
        last TRY_DIGITS if( ! exists( $$hash{$key} ) );                       # Bail out on good key
      }
      $char--;                                                                  # Go to previous character in key
    }
  }
  if( exists( $$hash{$key} ) && $key == 9999 ) {                                    # Check for existing key
    my $max = "9" x $length;
  NUMERIC: for( my $i = 0 ; $i <= $max ; $i++ ) {
      $key = ( "0" x ( $length - length( $i ) ) ) . $i;                         # Construct new numeric key
      last NUMERIC if( ! exists( $$hash{$key} ) );                              # Bail out on good key
    }
  }
  $object->debug( "ERROR\t$key" ) if( exists( $$hash{$key} ) );                     # DEBUG
  return( $key );                                                                   # Return computed key value
}
