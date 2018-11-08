#!/usr/local/bin/perl
#
#   NetSoup::XHTML::HyperGlot::Tree.pm v00.00.01z 12042000
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
#       method  -  description


package NetSoup::XHTML::HyperGlot::Tree;
use strict;
use NetSoup::Core;
use NetSoup::Files::Directory;
@NetSoup::XHTML::HyperGlot::Tree::ISA = qw( NetSoup::Core );
1;


sub tree {
  # This method descends a directory tree and extracts
  # the editable strings from the Html files found.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #          Pathname => $pathname
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $object   = shift;                                         # Get object
  my %args     = @_;                                            # Get arguments
  my $pathname = $args{Pathname};
  my $files    = NetSoup::Files::Directory->new();    #
  my $total = 0;






  return( $total );
}
