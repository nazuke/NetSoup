#!/usr/local/bin/perl
#
#   NetSoup::Packages::HyperGlot::bin::HyperGlot.pl v00.00.01z 12042000
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
#   Description: This Perl 5.0 script scans a directory tree of Html files
#                and seperates the editable text form the tags. The Html file is
#                tokenised with markers for the re-integration script.
#                Similarly a reverse process is also provided.
#
#
#         Usage: HyperGlot.pl pathname [ pathname ... ]
#
#                The program generates a HyperGlot file inside the
#                directory tree that is being processed. If this file
#                already exists then the strings from this file are
#                inserted back into the source files under the
#                directory tree.


use NetSoup::XHTML::HyperGlot;


my $glot = NetSoup::XHTML::HyperGlot->new();
foreach my $glot ( @ARGV ) {
  my $total = $glot->descend( Pathname => $pathname );
  if( $total ) {
    $glot->debug( "Grand Total:\t$total" );
  } else {
    $glot->debug( qq(Failed:\t"$pathname") );
  }
}
exit(0);
