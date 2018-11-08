#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::Cascade::CSS.pm v00.00.01a 12042000
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


package NetSoup::XHTML::MenuMaker::Drivers::Cascade::CSS;
use strict;
use NetSoup::Core;
@NetSoup::XHTML::MenuMaker::Drivers::Cascade::CSS::ISA = qw( NetSoup::Core );
my $CSS = join( "", <NetSoup::XHTML::MenuMaker::Drivers::Cascade::CSS::DATA> );
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
div.MMShell, span.MMph {
  font-family:         Verdana,sans-serif;
  font-size:           12px;
}

div.MMShell {
  position:            absolute;
  top:                 100px;
  left:                0px;
}

td.MMph, span.MMph {
  visibility:          hidden;
}




table.MMc {
  display:             block;
  margin-bottom:       0px;
  margin-left:         0px;
  margin-right:        0px;
  margin-top:          0px;
  padding-bottom:      0px;
  padding-left:        0px;
  padding-right:       0px;
  padding-top:         0px;
}

table.MMh {
  margin-bottom:       0px;
  margin-left:         0px;
  margin-right:        0px;
  margin-top:          0px;
  padding-bottom:      0px;
  padding-left:        0px;
  padding-right:       0px;
  padding-top:         0px;
}

table.MMm1, table.MMm2, table.MMm3, table.MMm4, table.MMm5, table.MMm6, table.MMm7, table.MMm8, table.MMm9 {
  display:             none;
  margin-bottom:       0px;
  margin-left:         0px;
  margin-right:        0px;
  margin-top:          0px;
  padding-bottom:      0px;
  padding-left:        0px;
  padding-right:       0px;
  padding-top:         0px;
}




td.MMc, td.MMph, .MMpd {
  font-family:         Verdana,sans-serif;
  font-size:           12px;
  height:              24px;
  padding-bottom:      4px;
  padding-left:        8px;
  padding-right:       8px;
  padding-top:         4px;
  vertical-align:      top;
}

td.MMc, td.MMph {
  color:               #FFFFFF;
  background-color:    #444488;
  border-style:        solid;
  border-width:        1px;
  border-top-color:    #666688;
  border-left-color:   #666688;
  border-right-color:  #000000;
  border-bottom-color: #000022;
  cursor:              hand;
}

.MMpd {
  height:              24px;
  font-size:           12px;
}




table.MMdesc {
  display:             none;
  position:            absolute;
  top:                 5px;
  left:                225px;
  width:               400px;
  height:              90px;
  background-color:    #DDDDFF;
  border-style:        solid;
  border-width:        1px;
  border-top-color:    #FFFFFF;
  border-bottom-color: #888888;
  border-left-color:   #AAAAAA;
  border-right-color:  #222222;
  margin-top:          0px;
  margin-bottom:       0px;
  margin-left:         0px;
  margin-right:        0px;
  z-index:             100;
}

table.MMDesc td {
  padding-top:         0px;
  padding-bottom:      0px;
  padding-left:        0px;
  padding-right:       0px;
}

table.MMDesc h1, table.MMDesc p {
  font-family:         sans-serif;
  font-size:           10px;
  margin-top:          2px;
  margin-bottom:       2px;
  margin-left:         5px;
  margin-right:        5px;
  color:               #000044;
  line-height:         20px;
}

table.MMDesc h1 {
  font-weight:         bold;
  padding-top:         0px;
}

table.MMDesc p {
  font-size:           10px;
}
