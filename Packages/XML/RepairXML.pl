#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::FormatXML.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script exercises the XML DOM class.


use strict;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::Files::Save;
use NetSoup::XML::Repair;


my @extensions = ( "xml", "html", "xhtml", "htm", "sgm", "sgml" );
foreach my $pathname ( @ARGV ) {
  if( -d $pathname ) {
    my $Directory = NetSoup::Files::Directory->new();
    $Directory->descend( Pathname    => $pathname,
                         Recursive   => 1,
                         Directories => 0,
                         Extensions  => \@extensions,
                         Callback    => sub {
                           my $pathname = shift;
                           repair( $pathname );
                         } );
  } else {
    repair( $pathname );
  }
}
exit(0);


sub repair {
  my $pathname = shift;
  my $data     = "";
  my $Load     = NetSoup::Files::Load->new();
  my $Save     = NetSoup::Files::Save->new();
  my $Repair   = NetSoup::XML::Repair->new();
  $Load->load( Pathname => $pathname,
               Data     => \$data );
  my $result = $Repair->repair( XML   => \$data,
                                Tries => 256 );
  if( $result == 0 ) {
    print( qq(Cannot repair "$pathname"\n) );
    return(0);
  } else {
    rename( $pathname, "$pathname~" );
    $Save->save( Pathname => $pathname,
                 Data     => \$data );
  }
  return(1);
}
