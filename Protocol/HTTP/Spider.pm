#!/usr/local/bin/perl
#
#   NetSoup::Protocol::HTTP::Spider.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class provides object methods for.
#
#
#   Methods:
#       method  -  description


package NetSoup::Protocol::HTTP::Spider;
use strict;
use NetSoup::Protocol::HTTP;
use NetSoup::URL::Parse;
use NetSoup::HTML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
@NetSoup::Protocol::HTTP::Spider::ISA = qw( NetSoup::Protocol::HTTP );
my $URLParse = NetSoup::URL::Parse->new();
my $DT  = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
1;


sub spider {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    Spider
  #    hash    {
  #              Depth => $depth
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Spider   = shift;                                  # Get object
  my %args     = @_;                                     # Get arguments
  my $Depth    = $args{Depth} || 0;                      # Link depth
  my $Filter   = $args{Filter};                          # Filters out unwanted documents
  my $Callback = $args{Callback};                        # Callback called on each document

  my $PROTOCOL = $URLParse->protocol( $args{URL} );
  my $HOSTNAME = $URLParse->hostname( $args{URL} );
  my $PATHNAME = $URLParse->pathname( $args{URL} );
  my $FILENAME = $URLParse->filename( $args{URL} );


  my $HTTP     = NetSoup::Protocol::HTTP->new();
  my $HTDOC    = $HTTP->get( URL => $args{URL} );


  if( defined $HTDOC ) {
    my $HTML     = $HTDOC->body();
    my $Parser   = $args{Parser} || NetSoup::HTML::Parser->new();
    my $Document = $Parser->parse( XML => \$HTML );
    $Spider->{History}->{$args{URL}} = 1;
    if( $Parser->flag( Flag => "Error" ) ) {    
      foreach my $error ( $Parser->errors() ) {
        print( STDERR "$error\n" ) if( $Spider->{Debug} );
      }
    }
    if( &$Callback( URL      => $args{URL},
                    HTML     => $HTML,
                    Document => $Document ) ) {
      my $Walker = $DT->createTreeWalker( Root   => $Document,
                                          Filter => sub {
                                            my $Node = shift;
                                            if( $Node->nodeName() =~ m/^a$/i ) {
                                              return(1);
                                            }
                                            return(0);
                                          } );
      $Walker->walkTree( Node     => $Document,                                           # TreeWalker spiders linked files
                         Callback => sub {
                           my $Node     = shift;
                           my $anchor   = ( $Node->getAttribute( Name => "HREF" ) ||
                                            $Node->getAttribute( Name => "href" ) );
                           my $hostname = $URLParse->hostname( $anchor );
                            my $pathname = $URLParse->pathname( $anchor );
                            my $filename = $URLParse->filename( $anchor );
                           return(1) if( $anchor =~ m/^(ftp|gopher|mailto):/i );
                           if( ( $hostname ) && ( $HOSTNAME ne $hostname ) ) {
                             return(1);
                           } else {
                             $anchor = join( "",
                                             "$PROTOCOL://",
                                             ( $hostname || $HOSTNAME ),
                                             $pathname,
                                             $filename );
                             if( ! exists $Spider->{History}->{$anchor} ) {
                               print( STDERR "\tRECURSING: $anchor\n" ) if( $Spider->{Debug} );
                               $Spider->spider( URL      => $anchor,
                                                Depth    => $Depth--,
                                                Callback => $Callback ) if( $Depth > 0 );
                               $Spider->{History}->{$anchor} = 1;
                             }
                           }
                           return(1);
                         } );
    }
  }
  return(1);
}
