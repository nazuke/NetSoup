#!/usr/local/bin/perl -w
#
#   NetSoup::XML::DOM2::Traversal::t::Serialise.pl v00.00.01a 12042000
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
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2;
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
  my $Parser            = NetSoup::XML::Parser->new();
  my $Document          = $Parser->parse( XML => \$data );
  if( defined $Document ) {
    my $DocumentTraversal = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
    my $Serialise         = $DocumentTraversal->createSerialise( WhatToShow               => undef,
                                                                 Filter                   => sub { return(1) },
                                                                 EntityReferenceExpansion => 0,
                                                                 CurrentNode              => $Document );
    my $target = "";
    $Serialise->serialise( Node   => $Document,
                           Target => \$target );
    print( STDERR $target );
    $Parser->debug( "Done" );
  } else {
    $Parser->debug( "Error" );
  }
  return(1);
}


__DATA__
<card type="special">
    <!-- These are the personal details -->
    <version value="1.0"/>
    <personal:details>
        <personal:name>
            <firstname>Armitage</firstname>
            <middlename>the</middlename>
            <lastname>III</lastname>
        </personal:name>
        <personal:address>
            <personal:number>1</personal:number>
            <personal:street>Police Precinct</personal:street>
            <personal:area>Mars Colony</personal:area>
        </personal:address>
    </personal:details>
    <professional:details>
       <professional:rank>Lieutenant</professional:rank>
    </professional:details>
</card>
