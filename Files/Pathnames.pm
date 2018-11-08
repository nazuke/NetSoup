#!/usr/local/bin/perl
#
#   NetSoup::Files::Pathnames.pm v00.00.01b 12042000
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
#   Description: This Perl 5.0 class provides object methods for manipulating Pathnames.
#
#
#   Methods:
#       resolve  -  This method resolves a relative pathname


package NetSoup::Files::Pathnames;
use strict;
use NetSoup::Files;
@NetSoup::Files::Pathnames::ISA = qw( NetSoup::Files );
1;


sub resolve {
  # This method resolves a relative pathname.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Pathname   => $pathname
  #              [Prefix    => $prefix]
  #              [Separator => $separator]
  #            }
  # Result Returned:
  #    scalar
  my $Pathnames = shift;                                        # Get object
  my %args      = @_;                                           # Get arguments
  my $pathname  = $args{Pathname}  || "/";                      # Get raw pathname
  my $prefix    = $args{Prefix}    || "";                       # Accept optional prefix
  my $sep       = $args{Separator} || $Pathnames->separator();  # Get directory separator
  if( $pathname !~ m:^\Q$sep\E: ) {                             # Look for missing prepending slash
    $pathname = $prefix . $pathname;                            # Prefix full pathname to relative pathname
  } elsif( $pathname =~ m:[^\.]\.\Q$sep\E: ) {                  # Look for HERE relative pathname
    $pathname =~ s:([^\.]?)\.{1}\Q$sep\E:$sep:g;                # Remove prepending .$sep sequence
    $prefix   =~ s:(\Q$sep\E?[^\Q$sep\E]+\Q$sep\E?){1,2}$::;    # Remove trailing two directories
    $pathname = $prefix . $pathname;                            # Prefix full pathname to relative pathname
    $pathname =~ s:\Q$sep\E+:$sep:g;                            # Convert all double slashes to single slash
  } elsif( $pathname =~ m:\.{2}\Q$sep\E: ) {                    # Look for PREVIOUS DIRECTORY relative pathname
    while( $pathname =~ m:\.{2}\Q$sep\E: ) {                    # Remove all relative directories
      my @source = split( /\Q$sep\E/, $pathname );              # Split on slashes
      my @resolved;
      foreach my $k ( @source ) {                               # Iterate over directory names
        if( $k =~ m:\.{2}:g ) {                                 # Remove previous directory if ..
          pop( @resolved );
        } else {
          push( @resolved, $k );                                # Otherwise append directory name
        }
      }
      $pathname = join( "$sep", @resolved );                    # Build resolved pathname
    }
  } else {
    ;                                                           # Do nothing - For the time being
  }
  return( $pathname );
}
