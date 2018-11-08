#!/usr/local/bin/perl -w
#
#   NetSoup::XHTML::Widgets::t::I18N.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the XHTML I18N Widget class.


use strict;
use NetSoup::XHTML::Widgets::I18N;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::Serialise;


foreach my $pathname ( @ARGV ) {
  my $data = "";
  open( FILE, $pathname );
  while( <FILE> ) { $data .= $_ }
  close( FILE );
  my $Parser   = NetSoup::XML::Parser->new( XML => \$data );
  my $Document = $Parser->parse();
  if( defined $Document ) {
    my $I18N = NetSoup::XHTML::Widgets::I18N->new( Document => $Document );
    if( defined $I18N ) {
      my $serialise = NetSoup::XML::DOM2::Traversal::Serialise->new();
      my $target    = "";
      $serialise->serialise( Node   => $Document,
                             Target => \$target );
      print( STDOUT $target );
    } else {
      print( STDOUT qq(ERROR: Not an XHTML Document "$pathname"\n) );
    }
  } else {
    print( STDOUT qq(ERROR: Invalid XHTML Document "$pathname"\n) );
  }
}
exit(0);
