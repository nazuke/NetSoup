#!/usr/local/bin/perl
#
#   NetSoup::Encoding::Win32RC.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class provides methods for encoding
#                data into a format suitable for win32 RC files.
#
#
#   Methods:
#       bin2hex  -  This method formats a chunk of data


package NetSoup::Encoding::Win32RC;
use strict;
use integer;
use NetSoup::Core;
use NetSoup::Text::CodePage::ascii2hex;
@NetSoup::Encoding::Win32RC::ISA = qw( NetSoup::Core );
1;


sub bin2hex {
  # This method formats a chunk of data into a plain text block in RC format.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              ID   => $id
  #              Name => $name
  #              Data => \$data
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $object = shift;                                            # Get object
  my %args   = @_;                                               # Get arguments
  my $data   = $args{Data};
  my $output = "$args{ID} $args{Name} FIXED IMPURE\nBEGIN\n";    #
  my $conv   = NetSoup::Text::CodePage::ascii2hex->new();
  $conv->ascii2hex( Data => $data );
  my @chars  = split( //, $$data );
  my $block  = "    ";
  my $count  = 0;
  while( @chars ) {
    if( $count >= 9 ) {
      $block .= "\n    ";
      $count  = 0;
    }
    my $left  = shift( @chars ) . shift( @chars );
    my $right = shift( @chars );
    if( defined $chars[-1] ) {
      $right .= shift( @chars );
    } else {
      $right = "0$right";
    }
    $block   .= "0x$right$left, ";
    $count++;
  }
  $block   =~ s/, +$//s;
  $output .= $block . "\nEND\n";
  return( $output );
}
