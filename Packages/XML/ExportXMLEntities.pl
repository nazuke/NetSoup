#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::ExportXMLEntities.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script applies the NetSoup XML
#                Parser to one or more files, and displays
#                any errors encountered.


use strict;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::XML::Parser::Preprocessor;
use NetSoup::XML::Util;


my $ACCEPTS  = NetSoup::XML::Util->accepts();
my %ENTITIES = ();
foreach my $pathname ( @ARGV ) {
  if( -d $pathname ) {
    my $Directory = NetSoup::Files::Directory->new();
    $Directory->descend( Pathname    => $pathname,
                         Recursive   => 1,
                         Directories => 0,
                         Extensions  => $ACCEPTS,
                         Callback    => sub { gather( (shift) ) } );
  } elsif( -f $pathname ) {
    gather( $pathname );
  } else {
    print( "Error\n" );
  }
}
if( open( FILE, ">ExportXMLEntities.log" ) ) {
  foreach my $key ( keys %ENTITIES ) {
    print( FILE "$key\t$ENTITIES{$key}\n" );
  }
  close(FILE);
} else {
  print( qq(Error: Cannot open "ExportXMLEntities.log"\n) );
}
exit(0);


sub gather {
  my $pathname = shift;
  my $data     = "";
  my $Load     = NetSoup::Files::Load->new();
  $Load->load( Pathname => $pathname,
               Data     => \$data );
  my $PP           = NetSoup::XML::Parser::Preprocessor->new();
  my $preprocessed = $PP->preprocessor( XML => \$data );
  if( ! defined $preprocessed ) {
    print( "$pathname\n" );
    foreach my $error ( $PP->errors() ) {
      print( "$error\n" );
    }
    return(0);
  } else {
    my $Entities = $PP->entities();
    foreach my $key ( keys %{$Entities} ) {
      $ENTITIES{$key} = $Entities->{$key};
    }
  }
  return(1);
}
