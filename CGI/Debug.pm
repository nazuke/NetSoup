#!/usr/local/bin/perl
#
#   NetSoup::CGI::Debug.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class library simulates a CGI environment to
#                facilitate the debugging of CGI scripts. It simulates the
#                effect of the CGI script being called by a web server.
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       getEnv      -  This method prints the set environment variables


package NetSoup::CGI::Debug;
use strict;
use NetSoup::Core;
@NetSoup::CGI::Debug::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #               Pathname => $pathname
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object          = shift;            # Get object
  my %args            = @_;               # Get arguments
  $object->{Pathname} = $args{Pathname};  # Get pathname
  $object->{ENV}      = $args{ENV};       # Get environment hash reference
  $object->{Vars}     = {};               # Anonymous hash contains variables to be set
  $object->_readConfig();                 # Read configuration file
  $object->_setEnv();                     # Configure environment variables
  return( $object );
}


sub _readConfig {
  # This private method reads and parses the configuration file.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $object->_readConfig();
  my $object = shift;
  if( open( FILE, $object->{Pathname} ) ) {
    my @vars;
    foreach my $i ( <FILE> ) {
      chop($i);
      push( @vars, $i );
    }
    foreach my $i ( @vars ) {
      my @temp = split( /\t/, $i );
      $object->{Vars}->{$temp[0]} = $temp[1];
    }
  } else {
    return(0);
  }
  return(1);
}


sub _setEnv {
  # This private method sets the environment variables.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $object->_setEnv();
  my $object  = shift;
  my $dir     = undef;
  foreach my $i ( sort keys %{$object->{Vars}} ) {
    if( $i =~ m/WORKING_DIR/i ) {
      $dir = $object->{Vars}->{$i};
    } else {
      $object->{ENV}->{$i} = $object->{Vars}->{$i};
    }
  }
  chdir( $dir ) if( $dir );
  return(1);
}


sub getEnv {
  # This method prints the set environment variables.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    $object->getEnv();
  my $object = shift;
  foreach my $i ( sort keys %{$object->{ENV}} ) {
    print( STDOUT "$i=$object->{ENV}->{$i}\n" );
  }
  return(1);
}
