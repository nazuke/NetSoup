#!/usr/local/bin/perl
#
#   NetSoup::Packages::HyperGlot::cgi-bin::Cookie.cgi v00.00.01z 12042000
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


use NetSoup::Protocol::HTTP_1::Core::Cookies;
use NetSoup::Util::Time;


my $cookie   = NetSoup::Protocol::HTTP_1::Core::Cookies->new();      # Get new cookie monster
my $time     = NetSoup::Util::Time->new();                           # Get new time object
my $hostname = $cookie->getConfig( Key => "HyperGlotHostname" );
line( "Content-type: text/plain" );                                  # Send content type
print( STDOUT $cookie->set( Key    => "HyperGlotStatus",             # Set new cookie
							Value  => "LoggedIn",
							Expire => $time->days(7),
							Domain => $hostname ) );
line( "Location: http://$hostname/HyperGlot/chooser/index.shtml" );  # Password OK, going to the chooser
line("");                                                            # Terminate HTTP header
exit(0);


sub line { print( STDOUT (shift) . "\r\n" ) }
