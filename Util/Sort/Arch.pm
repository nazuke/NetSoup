#!/usr/local/bin/perl
#
#   NetSoup::Util::Sort::Arch.pm v00.00.01b 12042000
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
#   Description: This Perl 5.0 class provides global methods for the
#                NetSoup Sort classes.
#
#
#   Methods:
#       archsort   -  This method thunks down to localsort()


package NetSoup::Util::Sort::Arch;
use strict;
use vars qw( $AUTOLOAD );
use NetSoup::Core;
@NetSoup::Util::Sort::Arch::ISA = qw( NetSoup::Core );
1;


sub archsort {
  # This method thunks down to localsort().
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           Array => \@array
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    $Sort->archsort( Array => \@array );
  my $Arch = shift;                  # Get object

  foreach my $key ( keys( %{$Arch->{Order}} ) ) {
    ;
  }





  return(1);
}
