#!/usr/local/bin/perl
#
#   NetSoup::HTML::Parser::Neanderthal.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides a shortcut to parsing
#                reasonably error free HTML files using the NetSoup
#                XML Parser.
#
#   Methods:
#       parse  -  This method parses a chunk of HTML text into a DOM2 parse tree


package NetSoup::HTML::Parser::Neanderthal;
use strict;
use NetSoup::Core;
use NetSoup::HTML::Parser::Neanderthal::Document;
@NetSoup::HTML::Parser::Neanderthal::ISA = qw( NetSoup::Core );
my $MODULE   = "Parser";
my $DOCUMENT = "NetSoup::HTML::Parser::Neanderthal::Document";


sub parse {
  # This method parses a chunk of XML text into a DOM2 parse tree.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash {
  #           XML => \$XML
  #         }
  # Result Returned:
  #    $Document || undef
  # Example:
  #    method call
  my $Neanderthal = shift;                                   # Get Parser
  my %args        = @_;                                      # Get arguments
  my $XML         = $args{XML};                              # Get XML data reference
  my @tags        = $Neanderthal->tags( XML => $XML );
  my @links       = $Neanderthal->links( Tags => \@tags );
  my @images      = $Neanderthal->images( Tags => \@tags );
  my $Document    = $DOCUMENT->new( HTML   => $XML,
                                    Links  => \@links,
                                    Images => \@images );
  return( $Document );                                       # Return Document object
}


sub tags {
  # This method returns an array of all of the tags in the scalar reference.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #            XML => \$XML
  #         }
  # Result Returned:
  #    array
  # Example:
  #    my @tags = $Neanderthal->tags( XML => \$XML);
  my $Neanderthal = shift;
  my %args        = @_;
  my $HTML        = $args{XML};
  my @tags        = ();
  if( defined $$HTML ) {
    $$HTML =~ s/(\r\n|\r|\n)+/ /gs;
    $$HTML =~ s/>/>\n/gs;
    $$HTML =~ s/</\n</gs;
    foreach my $line ( split( /\n/, $$HTML ) ) {
      if( $line =~ m/<[^>]+>/g ) {
        my ( $token ) = ( $line =~ m/[ \t]*(.+)[ \t]*/ );
        push( @tags, $token ) if( $token );
      }
    }
  }
  return( @tags );
}


sub links {
  my $Neanderthal = shift;
  my %args        = @_;
  my $tags        = $args{Tags};
  my @links       = ();
 LINK: foreach my $tag ( @{$tags} ) {
    next LINK if( ! defined $tag );
    my ( undef, undef, $found ) =
      ( $tag =~ m/^<(a|frame|link|script).+(href|src)=[\'\"]?([^\s^\'\"^>]+)[\'\"]?/i );
    if( defined $found ) {
      push( @links, $found );
    }
  }
  return( @links );
}


sub images {
  my $Neanderthal = shift;
  my %args        = @_;
  my $tags        = $args{Tags};
  my @images       = ();
 IMG: foreach my $tag ( @{$tags} ) {
    next IMG if( ! defined $tag );
    my ( $found ) = ( $tag =~ m/<img ?.*src=[\'\"]?([^\'\"^\s]+)[\'\"]?.*>/i );
    if( defined $found ) {
      push( @images, $found );
    }
  }
  return( @images );
}
