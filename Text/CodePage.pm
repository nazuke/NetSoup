#!/usr/local/bin/perl
#
#   NetSoup::Text::CodePage.pm v03.01.32b 12042000
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


package NetSoup::Text::CodePage;
use strict;
use NetSoup::Core;
@NetSoup::Text::CodePage::ISA = qw( NetSoup::Core );
1;


sub compact {
  # This method will compact a HEX encoded string into a smaller form.
  # Parameters Required:
  #    object
  #    scalar    hex encoded string
  # Result Returned:
  #    scalar    compact encoded string
  # Example:
  #    $compactEncodeString = $object->compactEncoded( $encodedString );
  my $object = shift;      # Get object
  my $string = shift;      # Get plain text string
  $string    =~ s/%//g;    # Remove all parcentage symbols
  return( $string );       # Return encode string
}


sub expand {
  # This method will expand a compact HEX encoded string into its original form.
  # Parameters Required:
  #    object
  #    scalar    compact encoded string
  # Result Returned:
  #    scalar    hex encoded string
  # Example:
  #    $expandedEncodeString = $object->expandEncoded( $compactEncodeString );
  my $object  = shift;                   # Get object
  my $string  = shift;                   # Get compact hex string
  my @chars   = split( //, $string );    # Split string into characters
  my $buf     = "";
  $string     = "";
  while( $buf = shift(@chars) ) {
    $buf    .= shift(@chars);
    $string .= '%' . $buf;
  }
  return( $string );                     # Return expanded string
}
