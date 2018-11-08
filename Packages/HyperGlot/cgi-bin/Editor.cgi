#!/usr/local/bin/perl
#
#   NetSoup::Packages::HyperGlot::cgi-bin::Editor.cgi v00.00.01z 12042000
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
#   Description: This Perl 5.0 script is part of the Online Html Editor.
#                This script displays the project editor frameset.


use NetSoup::CGI;


line( "Content-type: text/html\r\n" );                            # Output content type header
my $cgi  = NetSoup::CGI->new();
my $site = $cgi->field( Name => "site" );
foreach ( <DATA> ) {
	my $url = "http://$ENV{HTTP_HOST}/HyperGlot/editor/";    #
	s/(display.shtml)/$url$1/;
	s/(menu.shtml)/$url$1/;
	s/(editor.shtml)/$url$1/;
	line( $_ );
}
exit(0);


sub line { print( STDOUT (shift) . "\r\n" ) }


__DATA__
<html>
	<head>
		<title>HyperGlot</title>
	</head>
	<frameset rows="*,*">
		<frame name="DisplayPane" src="display.shtml">
		<frame name="EditorPane"  src="editor.shtml">
	</frameset>
</html>
