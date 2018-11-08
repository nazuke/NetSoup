#!/usr/local/bin/perl -w
#
#   NetSoup::Util::t::Hashes.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the Hashes.pm class.


use NetSoup::Util::Hashes;

my $object  = NetSoup::Util::Hashes->new();
my @strings = ();
my %hash    = ();
while( <DATA> ) {
  chomp;
  push( @strings, $_ ) if( $_ );
}
foreach my $string ( @strings ) {
  my $key     = $object->string2Key( Hash   => \%hash,
                                     String => \$string,
                                     Length => 4 );
  $hash{$key} = $string;
  #  $object->debug( "$key\t$string" );
}
exit(0);


__DATA__
How many cans
Jumps over the lazy dog
Jumps over the lazy dog
The quick brown fox
The quick brown fox
can a cannibal nibble
can nibble cans?
if a cannibal
spa
sp
