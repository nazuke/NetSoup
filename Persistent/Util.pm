#!/usr/local/bin/perl -w
#
#   NetSoup::Persistent::Util.pm v00.00.01b 12042000
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
#   Description: This Perl Class provides utility methods for the
#                NetSoup::Persistent classes.
#
#
#   Methods:
#       TIEHASH  -  This method is the object constructor for this class


package NetSoup::Persistent::Util;
use strict;
use Fcntl;                                               # Use Fcntl module for constants
use NetSoup::Core;                                       # Use Core class
@NetSoup::Persistent::Util::ISA = qw( NetSoup::Core );  # Configure inheritance tree
1;


sub _getlock {
  # This private method locks a file.
  my $Util     = shift;                   # Get object
  my %args     = @_;
  my $LOCKFILE = $args{LOCKFILE};
  my $LOCK_EX  = 2;                       # Define exclusive lock
  my $timeout  = 10;                      # Set timeout to n seconds
  my $lock     = 0;
 LOCK: while( $timeout > 0 ) {
    if( flock( $LOCKFILE, $LOCK_EX ) ) {  # Attempt to impose lock
      $lock++;                            # Raise lock flag
      last LOCK;                          # Break
    } else {
      $timeout--;
      sleep(1);
    }
  }
  return $lock;
}


sub _unique {
  # This method generates a unique filename based upon the reference type and the current date.
  # Calls:
  #    _packey
  # Parameters Required:
  #    object
  #    scalar    containing reference type
  # Result Returned:
  #    scalar    full pathname to file
  # Example:
  #    $filename = $Util->_unique( Pathname => $pathname, Ref => $ref );
  my $Util     = shift;                                        # Get class
  my %args     = @_;
  my $pathname = $args{Pathname} . "/";
  my $ref      = $args{Ref};                                   # Get reference type, if any
  my $filename = "";
  if( $ref ) {
    $ref = ".$ref";
  } else {
    $ref = "";
  }
  while( ! $filename ) {                                       # Wait for unique filename
    $filename = $pathname . $Util->_packey( time() ) . $ref;  # Build pathname
    $filename = "" if( -e $filename );                         # Check for existing pathname
  }
  return $filename;
}


sub _packey {
  # This private method packs the raw key.
  # Parameters Required:
  #    object
  #    scalar
  # Result Returned:
  #    scalar
  # Example:
  #    my $packed = $Util->_packey( $key );
  my $Util  = shift;               # Get object
  my $key     = shift;               # Get raw data
  my $encoded = "";                  # Will contain encoded key
  foreach ( split( //, $key ) ) {
    $encoded .= unpack( "H2", $_ );  # Convert bytes to hex notation
  }
  return $encoded;                   # Return encoded key
}


sub _unpackey {
  # This private method unpacks the encoded key.
  # Parameters Required:
  #    object
  #    scalar
  # Result Returned:
  #    scalar
  # Example:
  #    my $key = $Util->_unpackey( $packed );
  my $Util  = shift;                                # Get object
  my $encoded = shift;                                # Get encoded key
  my $key     = "";                                   # Will contain decoded key
  my @chars   = split( //, $encoded );                # Split into bytes
  while( @chars ) {                                   # Iterate over hex characters
    my $hexChar = shift( @chars ) . shift( @chars );  # Peel off two characters
    $key       .= pack( "H2", $hexChar );             # Pack hex into byte value
  }
  return $key;                                        # Return decoded key
}
