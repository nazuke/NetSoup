#!/usr/local/bin/perl
#
#   NetSoup::t::testcgi.cgi v00.00.01a 12042000
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
#   Description: This Perl script is used to test the HTTPD Server CGI capabilities.


use NetSoup::CGI;


my $cgi  = NetSoup::CGI->new( Debug => 0 );
my %hash = ();
line( "Content-Type: text/plain" );
line( "Content-Disposition: inline; filename=test" );
line( "" );
line( "Perl 5.0 Environment" );
line( "Perl Script: $0" );
line( "\r\nINC Array" );
foreach my $i ( @INC ) { line( $i ) }
line( "\r\nEnvironment Variables" );
foreach my $i ( keys %ENV ) { line( "$i\t$ENV{$i}" ) }
line( "\r\nField Names" );
foreach my $name ( $cgi->fields() ) {
	line( qq(ASCII Name="$name"\n) );
}
exit(0);
line( "\r\n/usr/sbin" );
my @programs = `ls /usr/sbin`;
foreach my $program ( @programs ) {
	chomp( $program );
	line( $program );
}
line( "\r\n/usr/bin" );
@programs = `ls /usr/bin`;
foreach my $program ( @programs ) {
	chomp( $program );
	line( $program );
}
line( "\r\n/usr/local/bin" );
@programs = `ls /usr/local/bin`;
foreach my $program ( @programs ) {
	chomp( $program );
	line( $program );
}
exit(0);


sub line { print( STDOUT (shift) . "\r\n" ) }
