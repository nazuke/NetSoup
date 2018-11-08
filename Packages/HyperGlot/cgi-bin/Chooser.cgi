#!/usr/local/bin/perl
#
#   NetSoup::Packages::HyperGlot::cgi-bin::Chooser.cgi v00.00.01z 12042000
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
#                This script displays the HyperGlot project chooser.


use NetSoup::CGI;
use NetSoup::Files::Directory;
use NetSoup::Text::CodePage::ascii2hex;


my $cgi       = NetSoup::CGI->new();
my $files     = NetSoup::Files::Directory->new();                                 # Get new directory object
my $ascii2hex = NetSoup::Text::CodePage::ascii2hex->new();
my $hostname  = $cgi->getConfig( Key => "HyperGlotHostname" );
my $cgipath   = $cgi->getConfig( Key => "HyperGlotCGIPath" );
line( "Content-type: text/html\r\n" );                                            # Output content type header
my $callback = sub {
	my $dir       = shift;                                                          # Get full pathname of virtual site
	my ( $label ) = ( $dir =~ m:^.+/([^/]+)$: );                                    # Extract hostname as label
	my $target    = $label;
	$ascii2hex->ascii2hex( Data => \$target );
	line( qq(<div class="buttonsLogin">) );
	line( "<p><form>" );                                                            # Entry preamble
	line( qq(<input type="button" value="Load" onClick="loadProj('$target')">) );   # Project load button
	line( "$label</form></p>" );                                                    # Output entry line
	line( qq(</div>) );
};
$files->descend( Pathname    => $files->getConfig( Key => "HyperGlotVirtPath" ),  # Scan directory
								 Directories => 1,
								 Recursive   => 0,
								 Callback    => $callback );
exit(0);


sub line { print( STDOUT (shift) . "\r\n" ) }
