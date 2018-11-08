#!/usr/local/bin/perl
#
#   NetSoup::Packages::HyperGlot::cgi-bin::Menu.cgi v00.00.01z 12042000
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
#                This script maps and displays a web site.


use NetSoup::CGI;
use NetSoup::Persistent::Store;
use NetSoup::Text::CodePage::ascii2hex;


$|++;                                                                 # Unbuffer STDOUT
exit(1) if( ! $ENV{HTTP_HOST} );                                      # Exit if no CGI environment
my %db     = ();                                                      # Global hash holds site map database
my $cgi    = NetSoup::CGI->new();                                     # Get new CGI object
my $dbPath = $cgi->getConfig( Key => "StorePath" ) . "/HyperGlot";    # Build HyperGlot DB pathname
if( tie %db, NetSoup::Persistent::Store, Pathname => $dbPath ) {      # Bind hash to database file
	my $site   = $cgi->field( Name => "site" );
	my $siteDB = $db{$site};
	if( $$siteDB{Mapped} == 1 ) {
		render( $siteDB );                                            # Render Html document
	} else {
		unmapped();                                                   # Report unmapped site
	}
} else {
	$cgi->debug( qq(Cannot bind "$dbPath") );                         # DEBUG
}
exit(0);                                                              # Exit on success


sub render {
	# This function renders the Html document.
	my $siteDB    = shift;                                                       # Get reference to database hash
	my $content   = $$siteDB{Content};                                           # Link to contents hash
	my $cgi       = NetSoup::CGI->new();                                         # Get new CGI object
	my $hex2ascii = NetSoup::Text::CodePage::ascii2hex->new();


	my $site      = $cgi->field( Name => "site" );
	$hex2ascii->hex2ascii( Data => \$site );




	my @pathlist  = ();                                                          # Holds list of paths
	my $leader    = "";                                                      # Scalar holds leading path segment
	foreach my $key ( sort( keys %$content ) ) {                  # Build path list


	}




	line( "Content-type: text/html\r\n" );
	line( qq(<table border="1">
			 <tr>
			 <td><h4>Path</h4></td>
			 <td><h4>Status</h4></td>
			 <td><h4>Username</h4></td>
			 </tr>) );


	foreach my $key ( sort( keys %$content ) ) {
		my $details  = $$content{$key};                                          # Link to details hash
		my $sitepath = sitepath();
		my $path     = $$details{Pathname};                                      # Store filename
		$path        =~ s/^\Q$sitepath\E//;
		line( qq(<tr>) );
		line( qq(
				 <td><p>
				 <a href="#" onClick="getPage('http://$site$path')">$path</a>
				 </p></td>
				 <td><p>$$details{Status}</p></td>
				 <td><p>$$details{Username}</p></td>
				) );
		line( qq(</tr>) );
	}


	line( qq(</table>) );
	return(1);
}


sub sitepath {
	# This function computes and verifies the site pathname.
	my $cgi      = NetSoup::CGI->new();                                 # Get new CGI object
	my $virtpath = $cgi->getConfig( Key => "HyperGlotVirtPath" );       # Get Apache virtual hosts path
	my $site     = $cgi->field( Name => "site", Format => "Ascii" );    # Get hostname of virtual site
	return( "$virtpath/HyperGlot/$site" );                              # Return absolute pathname
}




sub findlead {
	# This function finds the common leading path from an array of pathnames.
	my $array = shift; # Get array reference
	my $lead  = "";


	return( $lead );
}




sub line { print( STDOUT (shift) . "\r\n" ) }
