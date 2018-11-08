#!/usr/local/bin/perl
#
#   NetSoup::XHTML::Widgets::t::Table.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercies the Table.pm widget class.


use strict;
use NetSoup::XHTML::Widgets::Table;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::Serialise;


my $Table   = NetSoup::XHTML::Widgets::Table->new( Attributes => { "name"        => "A Nice Table",
                                                                   "border"      => 0,
                                                                   "cellpadding" => 0 } );
my @cells   = ( [ 1, 2, 3 ],
                [ 4, 5, 6 ],
                [ 7, 8, 9 ] );
my $target  = "";
my @colours = ( "red", "green", "blue" );
for( my $i = 0 ; $i < @cells ; $i++ ) {
  my $Row = $Table->createRow( Cells => $cells[$i] );
  $Row->setAttribute( Name  => "bgcolor",
                      Value => shift( @colours ) );
}
$Table->serialise( Target => \$target );
my $Parser    = NetSoup::XML::Parser->new();
my $Document  = $Parser->parse( XML => \$target );
my $Serialise = NetSoup::XML::DOM2::Traversal::Serialise->new();
$target       = "";
$Serialise->serialise( Node       => $Document,
                       Target     => \$target );
print( STDERR "\n" x 4 . $target );
exit(0);
