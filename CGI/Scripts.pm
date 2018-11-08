#!/usr/local/bin/perl
#
#   NetSoup::CGI::Scripts.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 provides methods for CGI scripts.
#
#
#   Methods:
#       this  -  This method returns the url of the calling script


package NetSoup::CGI::Scripts;
use strict;
use NetSoup::CGI;
@NetSoup::CGI::Scripts::ISA = qw( NetSoup::CGI );
1;


sub this {
  # This method returns the url of the calling script.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           Query => 0 | 1
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                                     # Get object
  my %args   = @_;                                        # Get arguments
  my $url    = join( "",                                  # Build script url
                     "http://",
                     $ENV{SERVER_NAME},
                     ":",
                     $ENV{SERVER_PORT},
                     $ENV{SCRIPT_NAME} );
  $url      .= "?$ENV{QUERY_STRING}" if( $args{Query} );  # If the caller wants the query string as well
  return( $url );
}
