#!/usr/local/bin/perl
#
#   NetSoup::t::Files.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script tests the NetSoup::Files class.


use NetSoup::Files;


my $object = NetSoup::Files->new();
my $source = "source";
my $dest   = "folder1/folder2/folder3/dest";
$object->debug( $object->copy( From  => $source,
                               To    => $dest,
                               Build => 1 ) );
if( -e "folder1/folder2/folder3/dest" ) {
  $object->debug( "NetSoup::t::Files.pl\tPassed" );
} else {
  $object->debug( "NetSoup::t::Files.pl\tFailed" );
  exit(-1);
}
exit(0);
