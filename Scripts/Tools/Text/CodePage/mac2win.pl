#!/usr/local/bin/perl
#
#   NetSoup::Scripts::Tools::Text::mac2win.pl v00.00.01a 12042000
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


use NetSoup::Text::CodePage::html2mac;
use NetSoup::Text::CodePage::html2win;


my $html2mac = NetSoup::Text::CodePage::html2mac->new();
my $html2win = NetSoup::Text::CodePage::html2win->new();


foreach ( @ARGV ) {
  rename( $_, "$_.old" );
  open( IN, "$_.old" );
  open( OUT, ">$_" );
  foreach ( <IN> ) {
    $html2mac->mac2html( Data => \$_ );
    $html2win->html2win( Data => \$_ );
    print( OUT $_ );
  }
  close( OUT );
  close( IN );
}


exit(0);
