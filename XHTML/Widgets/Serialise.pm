#!/usr/local/bin/perl
#
#   NetSoup::XHTML::Widgets::Serialise.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class manages XHTML widget serialisation
#                to an XML data stream.
#
#
#   Methods:
#       serialise  -  This method serialises the Table to an XML data stream


package NetSoup::XHTML::Widgets::Serialise;
use strict;
use NetSoup::Core;
use NetSoup::XML::DOM2::Traversal::Serialise;
@NetSoup::XHTML::Widgets::Serialise::ISA = qw( NetSoup::Core );
my $SERIALISE = "NetSoup::XML::DOM2::Traversal::Serialise";
1;


sub serialise {
  # This method serialises the XHTML widget to an XML data stream.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Target => \$target
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Widget    = shift;                               # Get Widget object
  my %args      = @_;                                  # Get arguments
  my $target    = $args{Target};                       # Get attributes hash reference
  my $Serialise = $SERIALISE->new();                   # Get new Serialise object
  $Serialise->serialise( Node   => $Widget->{Widget},  # Serialise to XML data stream
                         Target => $target );
  return(1);
}
