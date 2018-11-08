#!/usr/local/bin/perl
#
#   NetSoup::Files::Filenames.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides object methods for manipulating filenames.
#
#
#   Methods:
#       unique  -  This method generates a unique pathname


package NetSoup::Files::Filenames;
use strict;
use NetSoup::Files;
@NetSoup::Files::Filenames::ISA = qw( NetSoup::Files );
1;


sub unique {
  # This method generates a unique pathname based upon an abitrary string and the current date.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #           Pathname => $pathname
  #           [String  => $string]
  #            }
  # Result Returned:
  #    scalar      full pathname to file
  # Example:
  #    my $pathname = $object->unique();
  my $object   = shift;                                                                    # Get object
  my %args     = @_;                                                                       # Get arguments
  my $pathname = $args{Pathname};                                                          # Get pathname
  my $string   = $args{String} || "";                                                      # Get string
  my $filename = undef;                                                                    # Scalar will hold new filename
  my $sep      = $object->separator();                                                     # Get system directory separator
  $pathname    =~ s/$sep$//;                                                               # Strip trailing separator
  my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );  # Get current time
  my @nowDate  = ( $sec, $min, $hour, $mday, $mon, $year );                                # Build time string
  while( ! $filename ) {
    $filename  = join( "", @nowDate );
    $filename .= $string;
    $filename  =~ s/ /_/g;
    $filename  = $pathname . $object->separator() . $filename;                             # Join pathname elements
    $filename  = undef if( -e $filename );
  }
  return( $filename );
}
