#!/usr/local/bin/perl
#
#   NetSoup::Packages::HyperGlot::cgi-bin::Login.cgi v00.00.01z 12042000
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
#   Description: This Perl 5.0 script is part of the HyperGlot package.
#                This script validates and logs a user into the HyperGlot system.


use NetSoup::Auth::Passwd;
use NetSoup::CGI;
use NetSoup::Protocol::HTTP_1::Core::Cookies;
use NetSoup::Util::Time;


my $auth     = NetSoup::Auth::Passwd->new();
my $cgi      = NetSoup::CGI->new();
my $cookie   = NetSoup::Protocol::HTTP_1::Core::Cookies->new();
my $time     = NetSoup::Util::Time->new();
my $hostname = $auth->getConfig( Key => "HyperGlotHostname" );
SWITCH: for( $cgi->field( Name => "username" ) ) {
	m/\[void\]/i && do {                                                         # Looking for cookies
		line( "Content-type: text/plain\r\n" );
		if( $cookie->get( Key => "HyperGlotStatus" ) eq "LoggedIn" ) {             # Get value of login cookie
			print( STDOUT "/cgi-bin/HyperGlot/Cookie.cgi/" );                        # Go to chooser if already logged in
		} else {
			print( STDOUT "/HyperGlot/login/login.shtml" );                          # Go to login, if cookie missing or expired
		}
		last SWITCH;
	};
	m//i && do {                                                                 # Am I accepting username/password?
		if( $auth->authorise( Username => $cgi->field( Name => "username" ),
													Password => $cgi->field( Name => "password" ) ) ) {
			line( "Location: http://$hostname/cgi-bin/HyperGlot/Cookie.cgi\r\n" );   # Password OK, going to the chooser
		} else {
			line( "Location: http://$hostname/HyperGlot/login/invalid.shtml\r\n" );  # Invalid password
		}
		last SWITCH;
	};
}
exit(0);


sub line { print( STDOUT (shift) . "\r\n" ) }
