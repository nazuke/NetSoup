#!/usr/local/bin/perl
#
#   NetSoup::Scripts::Tools::Html::RipStuff::ripHtml.pl v00.00.01a 12042000
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
#         Usage: ripHtml.pl pathname [ pathname ... ]
#
#                A tilde character at the end of the pathname informs
#                the program that a 'stuff' action should occur.
#                A pathname with no tilde will cause a rip action.


use NetSoup::Core;
use NetSoup::Parse::Html::RipStuff::Files;


my $core   = NetSoup::Core->new();
my $ripper = NetSoup::Parse::Html::RipStuff::Files->new();
foreach my $pathname ( @ARGV ) {
  my $total = $ripper->execute( Pathname => $pathname );
  if( $total ) {
    $core->debug( "Grand Total:\t$total" );
  } else {
    $core->debug( qq(Failed:\t"$pathname") );
  }
}
exit(0);
