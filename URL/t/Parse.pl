#!/usr/local/bin/perl -w
#
#   NetSoup::URL::t::Parse.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the NetSoup::Parse::URL.pm class.


use NetSoup::URL::Parse;


my @urls = ( "http://dial.pipex.com/",
              "http://dial.pipex.com/index.html",
              "http://dial.pipex.com/folder/index.html",
              "http://dial.pipex.com/folder/folder1/index.html",
              "http://dial.pipex.com/folder/../index.html",
              "http://dial.pipex.com/folder/../folder1/index.html",
              "/folder/../folder1/index.html",
              "/folder/./folder1/index.html",
              "./folder/./folder1/index.html",
             "folder/file.html",
             "folder/file.html?query=yes",
             "http://localhost/?query=yes",
             "http://www.somehost.com",
             "http://www.somehost.com:8080/file.html" );
foreach ( @urls ) {
  my $Parse = NetSoup::URL::Parse->new();
  print "$_\n";
  my %hash = ();
  print( "\tProtocol\t\t" . $Parse->protocol( $_ ) . "\n" );
  print( "\tHostname\t\t" . $Parse->hostname( $_ ) . "\n" );
  print( "\tPort    \t\t" . $Parse->port( $_ ) . "\n" );
  print( "\tPathname\t\t" . $Parse->pathname( $_ ) . "\n" );
  print( "\tFilename\t\t" . $Parse->filename( $_ ) . "\n" );
  print( "\tQuery\t\t"    . $Parse->query( $_ )    . "\n" );
  print "\n\n";
}
exit(0);
