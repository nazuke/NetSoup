#!/usr/local/bin/perl
#
#   NetSoup::Util::Sort::Arch::t::Mac.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the Mac.pm sorting class.


use NetSoup::Util::Sort::Arch::Mac;
use NetSoup::Util::Arrays;
my $macsort = NetSoup::Util::Sort::Arch::Mac->new();
my $shuffle = NetSoup::Util::Arrays->new();
my @array   = ();
while ( <DATA> ) {
  chop;
  push( @array, $_ ) if( $_ );
}
$shuffle->shuffle( Array => \@array );
foreach ( @array ) { print "$_\n" }
print "\n" x 4;
$macsort->archsort( Array    => \@array,
                    Callback => sub { my $string = shift;
                                      print( STDERR "$string\n" ); } );
print "\n" x 4;
foreach ( @array ) { print "$_\n" }
exit(0);


__DATA__
The quick brown fox
jumps over the lazy dog
The quick brown fox
jumps over the lazy dog
The quick brown fox
jumps over the lazy dog
The quick brown fox
jumps over the lazy dog
a
b
c
d
e
f
g
h
i
j
k
l
m
n
o
p
q
r
s
t
u
v
w
x
y
z
