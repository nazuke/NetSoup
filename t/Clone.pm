#!/usr/local/bin/perl
#
#   NetSoup::t::Clone.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class tests NetSoup object cloning.


package NetSoup::t::Clone;
use strict;
use NetSoup::Core;
@NetSoup::t::Clone::ISA = qw( NetSoup::Core );


sub initialise {
  my $object = shift;
  foreach my $i ( 0 .. 2 ) {
    $object->{$i} = [ 1, 2, 3 ];
  }
  $object->{SPAM} = { One   => 1,
            Two   => 2,
            Three => 3 };
  return(1);
}


sub inc {
  my $object = shift;
  foreach my $i ( 0 .. 2 ) {
    $object->{$i} = [ 2, 3, 4 ];
  }
  $object->{SPAM} = { One   => 2,
            Two   => 3,
            Three => 4 };
  return(1);
}
