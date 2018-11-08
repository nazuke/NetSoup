#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::W3C::CSS.pm v00.00.01a 12042000
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


package NetSoup::XHTML::MenuMaker::Drivers::W3C::CSS;
use strict;
use NetSoup::Core;
@NetSoup::XHTML::MenuMaker::Drivers::W3C::CSS::ISA = qw( NetSoup::Core );
my $CSS = join( "", <NetSoup::XHTML::MenuMaker::Drivers::W3C::CSS::DATA> );
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
div.MM1,div.MM2,div.MM3,div.MM4,div.MM5 {
  position:     absolute;
  border-color: #000000;
  border-style: solid;
  border-width: 1px;
  font-family:  sans-serif;
  font-size:    8pt;
  font-weight:  bold;


  xvisibility:  hidden;
  display:      none;


}

div.MM1 {
  background-color: #002287;
  color:            #FFFFFF;
  left:             0px;
  top:              170px;


  xvisibility:      visible;
  display:          block;


  width:            100%;
  z-index:          1;
}

div.MM2 {
  background-color: #113388;
  color:            #FFFFFF;
  left:             0px;
  top:              0px;
  z-index:          2;
}

div.MM3 {
  background-color: #224489;
  color:            #FFFFFF;
  left:             0px;
  top:              0px;
  z-index:          3;
}

div.MM4 {
  background-color: #33558A;
  color:            #FFFFFF;
  left:             0px;
  top:              0px;
  z-index:          4;
}

div.MM5 {
  background-color: #44668B;
  color:            #FFFFFF;
  left:             0px;
  top:              0px;
  z-index:          5;
}

table.MM1 {
}

table.MMMenu {
}

td.MM {
  border-bottom-color: #666666;
  border-left-color:   #BBBBBB;
  border-right-color:  #888888;
  border-style:        solid;
  border-top-color:    #CCCCCC;
  border-width:        1px;
  padding-bottom:      4px;
  padding-left:        8px;
  padding-right:       8px;
  padding-top:         4px;
}

a.MMB:link,a.MMB:hover,a.MMB:visited {
  color:           #FFFFFF;
  font-family:     sans-serif;
  font-size:       8pt;
  font-weight:     bold;
  text-decoration: none;
}
