#!/usr/local/bin/perl
#
#   NetSoup::Files::Convert::Any2Dos.pm v00.00.01a 12042000
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
#       _convert  -  This private method converts Unix line endings to DOS format


package NetSoup::Files::Convert::Any2Dos;
use strict;
use NetSoup::Files::Convert;
@NetSoup::Files::Convert::Any2Dos::ISA = qw( NetSoup::Files::Convert );
1;


sub _convert {
  # This private method converts Unix line endings to DOS format.
  # Calls:
  #    none
  # Parameters Required:
  #    Convert
  #    hash    {
  #              Data => \$Data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Convert->_convert( Data => \$Data );
  my $Convert = shift;                # Get Convert object
  my %args    = @_;                   # Get arguments
  my $Data    = $args{Data};          # Get text data
  $$Data      =~ s/\x0A/\x0D\x0A/gs;  # Convert line endings to \r\n
  return(1);
}
