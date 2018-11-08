#!/usr/local/bin/perl
#
#   NetSoup::Text::CodePage::t::testcs.cgi v00.00.01a 12042000
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
#   Description: This Perl script exercises the character set conversion functions.


use NetSoup::Text::CodePage::html2mac;


@raw = <DATA>;

my $object = NetSoup::Text::CodePage::html2mac->new();

foreach my $i ( @raw ) {
  line( "PLAIN\n$i" );
  $object->mac2html( Data => \$i );
  line( "mac2html\n$i" );
  $object->html2mac( Data => \$i );
   line( "html2mac\n$i" );
  line("");
}


sub line { print( STDOUT (shift) . "\n" ) }


#__DATA__
#The quick brown fox jumps over the lazy dog.
#�1234567890-=
#�!@�$%^&*()_+
#qwertyuiop[]asdfghjkl;'\`zxcvbnm,./
#QWERTYUIOP{}ASDFGHJKL:"|~ZXCVBNM<>?


__DATA__
The quick brown fox jumps over the lazy dog.
�!@�$%^&*()_+
