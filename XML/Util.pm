#!/usr/local/bin/perl
#
#   NetSoup::XML::Util.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides some utility methods.
#
#   Methods:
#       parse  -  This method parses a chunk of XML text into a DOM2 parse tree.


package NetSoup::XML::Util;
use strict;
use NetSoup::Core;
@NetSoup::XML::Util::ISA = qw( NetSoup::Core );
1;


sub accepts {
  # This method returns a list of acceptable filename extensions.
  # Each extension is returned as a regex.
  # Calls:
  #    none
  # Parameters Required:
  #    Util
  # Result Returned:
  #    array
  # Example:
  #    method call
  my $Util    = shift;          # Get Util
  my @accepts = (
     "[xX]([mM]|[sS])[lL]",     # XML
     "[xX]?[hH][tT][mM][lL]?",  # HTML and XHTML
     "[sS][gG][mM][lL]?",       # SGML
     "[eE][nN][tT]?"            # ENT
    );
  return( \@accepts );          # Return array reference
}
