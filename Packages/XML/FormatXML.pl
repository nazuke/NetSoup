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
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use NetSoup::XML::Util;


if( @ARGV ) {
  foreach my $pathname ( @ARGV ) {
    if( -d $pathname ) {
      my $Directory = NetSoup::Files::Directory->new();
      $Directory->descend( Pathname    => $pathname,
                           Recursive   => 1,
                           Directories => 0,
                           Extensions  => NetSoup::XML::Util->accepts(),
                           Callback    => sub {
                             my $pathname = shift;
                             file( $pathname );
                           } );
    } else {
      file( $pathname );
    }
  }
} else {
  filter();
}
exit(0);


sub filter {
  my $data   = join( "", <STDIN> );
  my $target = reformat( \$data ) || \$data;
  print( STDOUT $$target );
  return(1);
}


sub file {
  my $pathname = shift;
  my $data     = "";
  my $Load     = NetSoup::Files::Load->new();
  my $Save     = NetSoup::Files::Save->new();
  $Load->load( Pathname => $pathname,
               Data     => \$data );
  print( "$pathname\n" );
  my $target = reformat( \$data );
  if( defined $target ) {
    rename( $pathname, "$pathname~" );
    $Save->save( Pathname => $pathname,
                 Data     => $target );
    if( $^O =~ m/mac/i ) {
      MacPerl::SetFileInfo( 'R*ch', "TEXT", $pathname );
    }
  } else {
    return(0);
  }
  return(1);
}


sub reformat {
  my $data     = shift;
  my $target   = "";
  my $Parser   = NetSoup::XML::Parser->new();
   my $Document = $Parser->parse( XML        => $data,
                                 Whitespace => "compact" );
  if( $Parser->flag( Flag => "Error" ) ) {
    foreach my $error ( $Parser->errors() ) {
      print( STDERR $error );
    }
    return( undef );
  } else {
    my $DocumentTraversal = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
    my $Serialise         = $DocumentTraversal->createSerialise( WhatToShow               => undef,
                                                                 Filter                   => sub {},
                                                                 EntityReferenceExpansion => 0,
                                                                 CurrentNode              => $Document );
    $Serialise->serialise( Node   => $Document,
                           Indent => 0,
                           Target => \$target );
  }
  return( \$target );
}
