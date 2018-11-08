#!/usr/local/bin/perl
#
#   NetSoup::XHTML::Widgets::Table::text2table.pm v00.00.01a 12042000
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
#       text2table  -  This method converts a text block into an XHTML table


package NetSoup::XHTML::Widgets::Table::text2table;
use strict;
use NetSoup::Core;
use NetSoup::XHTML::Widgets::Table;
@NetSoup::XHTML::Widgets::Table::text2table::ISA = qw( NetSoup::Core );
1;


sub text2table {
  # This method converts a text block into an XHTML table.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Content   => $content
  #              Separator => $separator
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;
  my %args   = @_;
  my $sep    = $args{Separator} || "\t";
  my @table  = ();
  my @row    = split( /(\r\n|\r|\n)/, $args{Content} );  #
  my $Table  = NetSoup::XHTML::Widgets::Table->new();    # Get new Table Widget
  foreach my $row ( @row ) {
    chomp( $row );
    next if( length( $row ) == 0 );
    my @cells = split( /$sep/, $row );
    $Table->createRow( Cells => \@cells );
  }
  return( $Table );                                      # Return Table Widget object
}
