#!/usr/local/bin/perl
#
#   NetSoup::Auth::t::Passwd.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the Passwd.pm class.


use NetSoup::Auth::Passwd;


my $object   = NetSoup::Auth::Passwd->new();
my $username = "";
my $password = "";
print( STDOUT "Enter username: " );
$username = <STDIN>;
chomp( $username );
print( STDOUT "\n" );
print( STDOUT "Enter password: " );
$password = <STDIN>;
chomp( $password );
print( STDOUT "\n" );
if( $object->authorise( Username => $username,
                        Password => $password ) ) {
  print( STDOUT "Valid Password\n" );
} else {
  print( STDOUT "Invalid Password\n" );
}
exit(0);
