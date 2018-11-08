#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::NS4::CSS.pm v00.00.01a 12042000
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
#       method  -  description


package NetSoup::XHTML::MenuMaker::Drivers::NS4::CSS;
use strict;
use NetSoup::Core;
@NetSoup::XHTML::MenuMaker::Drivers::NS4::CSS::ISA = qw( NetSoup::Core );
my $CSS = join( "", <NetSoup::XHTML::MenuMaker::Drivers::NS4::CSS::DATA> );
1;


sub css {
  # This method returns the Stylesheet text.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $JavaScript = shift;  # Get object
  my %args       = @_;     # Get arguments
  return( $CSS );
}


__DATA__
table.MenuMaker1 {
  position:         absolute;
  top:              170px;
  left:             0px;
  font-family:      sans-serif;
  font-size:        14pt;
  font-weight:      bold;
  background-color: #002287;
  color:            #FFFFFF;
  visibility:       show;
  z-index:          1;
}

table.MenuMaker2 {
  position:         absolute;
  top:              0px;
  left:             0px;
  font-family:      sans-serif;
  font-size:        14pt;
  font-weight:      bold;
  visibility:       hide;
  background-color: #113388;
  color:            #FFFFFF;
  z-index:          2;
}

table.MenuMaker3 {
  position:         absolute;
  top:              0px;
  left:             0px;
  font-family:      sans-serif;
  font-size:        14pt;
  font-weight:      bold;
  visibility:       hide;
  background-color: #224489;
  color:            #FFFFFF;
  z-index:          3;
}

table.MenuMaker4 {
  position:         absolute;
  top:              0px;
  left:             0px;
  font-family:      sans-serif;
  font-size:        14pt;
  font-weight:      bold;
  visibility:       hide;
  background-color: #33558A;
  color:            #FFFFFF;
  z-index:          4;
}

table.MenuMaker5 {
  position:         absolute;
  top:              0px;
  left:             0px;
  font-family:      sans-serif;
  font-size:        14pt;
  font-weight:      bold;
  visibility:       hide;
  background-color: #44668B;
  color:            #FFFFFF;
  z-index:          5;
}

td.MenuMaker {
  padding-top:    4px;
  padding-bottom: 4px;
  padding-left:   8px;
  padding-right:  8px;
  border-color:   #888888;
  border-style:   solid;
  border-width:   1px;
}

a.MenuMakerButton:link,a.MenuMakerButton:hover,a.MenuMakerButton:visited {
  color:           #FFFFFF;
  font-family:     sans-serif;
  font-size:       14pt;
  font-weight:     bold;
  text-decoration: none;
}

a.MenuMakerButton:hover {
  color: #FF0000;
}
