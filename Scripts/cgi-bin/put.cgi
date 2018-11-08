#!/usr/local/bin/perl
#
#   NetSoup::Scripts::cgi-bin::put.cgi v00.00.01b 12042000
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
#   Description: This Perl 5.0 script implements a PUT method for
#                the Apache web server on Unix style systems.


use NetSoup::CGI;


my $cgiObj = NetSoup::CGI->new();
print( STDOUT "Status: 201 Created\r\n" );
print( STDOUT "Content-Type: text/html\r\n" );
print( STDOUT "\r\n" );
if( exists $ENV{REQUEST_METHOD} ) {
	store( $cgiObj ) || last;
	print( STDOUT "<html><head><title>Created</title></head>\r\n" );
	print( STDOUT "<body><h1>Created</h1</body></html>\r\n" );
	exit(0);
}
exit error();


sub store {
	# This function creates the file.
	my $cgiObj   = shift;                                # Get CGI object
	my $pathname = $cgiObj->var( "PATH_TRANSLATED" );    # Build full path to requested document
	my $length   = $cgiObj->var( "CONTENT_LENGTH" );     # Get length of incoming data
	my $data     = "";                                   # New scalar will store document body
	while( <STDIN> ) { $data .= $_ }                     # Read incoming data
	return(0) if( length( $data ) != $length );          # Check length
	open( FILE, ">$pathname" ) || return(0);             # Open file for writing or fail
	print( FILE $data );                                 # Write data to new file
	close( FILE );                                       # Close file
	return(1);
}


sub error {
	print( STDOUT "<html><head><title>Created</title></head>\r\n" );
	print( STDOUT "<body><h1>Error</h1</body></html>\r\n" );
	return(1);
}
