#!/usr/local/bin/perl -w
#
#   NetSoup::XML::t::Serialise.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the XML DOM class.


use strict;
use NetSoup::XML::DOM2;
use NetSoup::XML::DOM2::Core::Element;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;


if( $ARGV[0] ) {
  foreach my $pathname ( @ARGV ) {
    my $data = "";
    print( STDERR "$pathname\n" );
    open( FILE, $pathname );
    while( <FILE> ) { $data .= $_ }
    close( FILE );
    harness( $data );
  }
} else {
  my $data = "";
  while( <DATA> ) { $data .= $_ }
  harness( $data );
}
exit(0);


sub harness {
  my $data              = shift;
  my $DOM               = NetSoup::XML::DOM2->new();
  my $Document          = $DOM->parse( XML => \$data );
  my $DocumentTraversal = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
  my $Serialise         = $DocumentTraversal->createSerialise( WhatToShow               => undef,
                                                               Filter                   => sub {},
                                                               EntityReferenceExpansion => 0,
                                                               CurrentNode              => $Document );
  my $target = "";
  $Serialise->serialise( Node   => $Document,
                         Target => \$target );
  print( STDERR $target );
  $DOM->debug( "Done" );
  return(1);
}


__DATA__
<card>
  <!-- These are the personal details -->
    <details>
        <name>
            <firstname>Armitage</firstname>
            <middlename>the</middlename>
            <lastname>III</lastname>
        </name>
        <address>
            <number>1</number>
            <street>Police Precinct</street>
            <area>Mars Colony</area>
        </address>
    </details>
</card>
