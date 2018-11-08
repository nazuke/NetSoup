#!/usr/local/bin/perl
#
#   NetSoup::Files::Directory::Recurse.pm v00.00.01b 12042000
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
#   Description: This Perl 5.0 class provides a simple wrapper over the
#                NetSoup portable directory scanning class.
#
#
#   Methods:
#       recurse  -  This method descends an array of pathnames


package NetSoup::Files::Directory::Recurse;
use strict;
use NetSoup::Files::Directory;
@NetSoup::Files::Directory::Recurse::ISA = qw( NetSoup::Files::Directory );
1;


sub recurse {
  # This method descends an array of pathnames.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hashref {
  #              Array       => \@array
  #              Recursive   => 0 | 1
  #              Directories => 0 | 1
  #              Callback    => sub { my $path = shift }
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                                     # Get object
  my %args   = @_;                                        # Get arguments
  foreach my $pathname ( @{$args{Array}} ) {              # Iterate over array, descending each pathname
    $object->descend( Pathname    => $pathname,
                      Recursive   => $args{Recursive},
                      Directories => $args{Directories},
                      Callback    => $args{Callback} );
  }
  return(1);
}
