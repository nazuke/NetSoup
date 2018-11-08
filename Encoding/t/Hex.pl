#!/usr/local/bin/perl
#
#   NetSoup::Encoding::t::Hex.pl v00.00.01a 12042000
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
#   Description: This Perl script exercises the Hex encoding module.


use strict;
use NetSoup::Encoding::Hex;


my $Raw     = 'The quick brown fox jumps over the lazy dog 01234567890 !"£$%^&*()_+';
my $Encoded = "";
my $Decoded = "";
my $Hex     = NetSoup::Encoding::Hex->new();
line( qq(RAW     "$Raw") );
$Encoded = $Hex->bin2hex( Data => $Raw );
line( qq(ENCODED "$Encoded") );
$Decoded = $Hex->hex2bin( Data => $Encoded );
line( qq(DECODED "$Decoded") );
sub line { print( STDOUT (shift) . "\n" ) }
