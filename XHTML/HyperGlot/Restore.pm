#!/usr/local/bin/perl
#
#   NetSoup::XHTML::HyperGlot::Restore.pm v00.00.01z 12042000
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
#       replace  -  This method puts the new strings into the Html data


package NetSoup::XHTML::HyperGlot::Restore;
use strict;
use NetSoup::XHTML::HyperGlot::Report;
@NetSoup::XHTML::HyperGlot::Restore::ISA = qw( NetSoup::XHTML::HyperGlot::Report );
1;


sub replace {
  # This method puts the new strings into the Html data.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Report => \$report
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                               # Get object
  my %args   = @_;                                  # Get arguments


  $object->_unreport( Report => $args{Report} );    # Restore record member



  return(1);
}
