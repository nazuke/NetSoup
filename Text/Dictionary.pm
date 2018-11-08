#!/usr/local/bin/perl
#
#   NetSoup::Text::Dictionary.pm v00.00.01g 12042000
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
#       lookup  -  This method determines if a word is in the dictionary


package NetSoup::Text::Dictionary;
use strict;
use NetSoup::Core;
@NetSoup::Text::Dictionary::ISA = qw( NetSoup::Core );
1;


sub lookup {
  # This method determines if a word is in the dictionary.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Word => $word
  #              Raw  => undef | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                      # Get object
  my %args   = @_;                         # Get arguments
  my $word   = lc( $args{Word} );          # Get word to look up
  if( ! exists( $args{Raw} ) ) {           # If Raw is set then pre-process word
    $word =~ s/\'\w+//g;                   # Remove apostrophe and trailing characters
    $word =~ s/[!-@[-`{-~]+//g;            # Remove punctuation
  }
  if( exists $object->{List}->{$word} ) {  # Look for word in dictionary
    return(1);
  } else {
    return(0);
  }
}
