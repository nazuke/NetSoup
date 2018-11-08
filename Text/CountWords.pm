#!/usr/local/bin/perl
#
#   NetSoup::Text::CountWords.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides methods for counting words.
#
#
#   Methods:
#       count  -  This method performs a simple word count on a chunk of plain text


package NetSoup::Text::CountWords;
use strict;
use NetSoup::Core;
@NetSoup::Text::CountWords::ISA = qw( NetSoup::Core );
1;


sub count {
  # This method performs a simple word count on a chunk of plain text.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Text => \$text
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    $count = $CountWords->count( Text => \$text );
  my $CountWords = shift;                                         # Get object
  my %args       = @_;                                            # Get arguments
  my $text       = $args{Text};                                   # Get reference to data
  my @ignore     = ( 0   .. 47,                                   # List of characters to ignore
                     58  .. 64,
                     91  .. 96,
                     123 .. 127 );
  my $total      = 0;                                             # Initialise counter
  foreach my $line ( split( /(\x0D\x0A|\x0D|\x0A)/, $$text ) ) {  # Split into line oriented records
    $line     =~ s/[ \t]+/ /gs;                                   # Compact white space
    my @words = ( split( / /, $line  ) );                         # Split into words
  WORD: foreach my $word ( @words ) {                             # Count number of words
      foreach my $skip ( @ignore ) {                              # Ignore certain words
        next WORD if( $word eq chr( $skip ) );
      }
      $total++ if( $word );                                       # This word is acceptable
    }
  }
  return( $total );
}
