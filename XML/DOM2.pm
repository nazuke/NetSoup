#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class is part of the DOM2 XML system.
#                This is basically a stub class that collects together
#                the XML Parser and DOM classes.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class.


package NetSoup::XML::DOM2;
use strict;
use NetSoup::XML::DOM2::Core::Document;
@NetSoup::XML::DOM2::ISA = qw( NetSoup::XML::DOM2::Core::Document );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $DOM2 = NetSoup::XML::DOM2->new();
  my $DOM2 = shift;  # Get object
  my %args = @_;     # Get arguments
  return( $DOM2 );
}
