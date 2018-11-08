#!/usr/local/bin/perl -w
#
#   NetSoup::Packages::XML::LanguageXML.pl v00.00.01a 12042000
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
use NetSoup::Text::Language;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
use NetSoup::XML::Util;


my $NoFiles = 0;
my %Totals  = ();
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
print( "\nTotal No. Files\t$NoFiles\n\n" );
foreach my $key ( sort keys %Totals ) {
  my $value   = $Totals{$key};
  my $percent = ( 100 / $NoFiles ) * $value;
  print( "\t$key\t$value\t$percent\%\n" );
}
exit(0);


sub file {
  my $pathname    = shift;
  my $data        = "";
  my $Load        = NetSoup::Files::Load->new();
  $Load->load( Pathname => $pathname, Data => \$data );
  my $lang        = language( \$data );
  $NoFiles       += 1;
  $Totals{$lang} += 1;
  print( "$pathname\t$lang\n" );
  return( $lang );
}


sub language {
  my $XML      = shift;
  my $Text     = "";
  my $lang     = "ERROR";
  my $Language = NetSoup::Text::Language->new();
  my $Parser   = NetSoup::XML::Parser->new();
   my $Document = $Parser->parse( XML        => $XML,
                                 Whitespace => "compact" );
  if( $Parser->flag( Flag => "Error" ) ) {
    foreach my $error ( $Parser->errors() ) {
      print( STDERR $error );
    }
    return( $lang );
  } else {
    my $DocumentTraversal = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
    my $TreeWalker        = $DocumentTraversal->createTreeWalker( CurrentNode              => $Document,
                                                                  WhatToShow               => undef,
                                                                  Filter                   => sub {
                                                                    my $Node = shift;
                                                                    if( $Node->nodeType() =~ m/TEXT_NODE/ ) {
                                                                      return(1);
                                                                    }
                                                                  },
                                                                  EntityReferenceExpansion => 0 );
    $TreeWalker->walkTree( Node     => $Document,
                           Callback => sub {
                             my $Node = shift;
                             $Text   .= $Node->nodeValue() . "\n";
                             return(1);
                           } );
  }
  $lang = $Language->identify( Text => \$Text ) || "UNKNOWN";
  return( $lang );
}
