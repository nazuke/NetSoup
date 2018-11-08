#!/usr/local/bin/perl
#
#   NetSoup::Protocol::HTTP::Spider::Simple.pm v00.00.01a 12042000
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


package NetSoup::Protocol::HTTP::Spider::Simple;
use strict;
#use Thread;
use NetSoup::Core;
use NetSoup::URL::Parse;
use NetSoup::Protocol::HTTP;
use NetSoup::HTML::Parser::Simple;
use NetSoup::HTML::Parser::Neanderthal;
@NetSoup::Protocol::HTTP::Spider::Simple::ISA = qw( NetSoup::Core );
my $MAXTHREADS = 16;
my $THREADS    = 0;
my $URLParse   = NetSoup::URL::Parse->new();
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Debug  => 0 | 1
  #              Parser => "Simple" | "Neanderthal"
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Simple        = shift;                          # Get object
  my %args          = @_;                             # Get arguments
  $Simple->{Debug}  = $args{Debug}  || 0;
  $Simple->{Parser} = $args{Parser} || "neaderthal";  # Select HTML Parser module
  return( $Simple );
}


sub spider {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    Spider
  #    hash    {
  #              URL   => $URL
  #              Depth => $depth
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Simple   = shift;                                                      # Get object
  my %args     = @_;                                                         # Get arguments
  my $Depth    = $args{Depth}  || 1000;                                      # Link depth
  my $RLevel   = $args{RLevel} || 0;                                         # Recursion level
  my $Filter   = $args{Filter};                                              # Filters out unwanted documents
  my $Callback = $args{Callback};                                            # Callback called on each document
  my $Images = $args{Images} || 0;                                            # Callback called on each document
  my $PROTOCOL = $URLParse->protocol( $args{URL} );
  my $HOSTNAME = $URLParse->hostname( $args{URL} );
  my $PATHNAME = $URLParse->pathname( $args{URL} );
  my $FILENAME = $URLParse->filename( $args{URL} );
  my $HTTP     = NetSoup::Protocol::HTTP->new();
  my $HTDOC    = $HTTP->get( URL => $args{URL} );
  if( $Simple->{Debug} ) {
    print( "  " x $RLevel . qq("$args{URL}"  ) );
    print( $HTDOC->field( Name => "Content-Type" ) . "\n" );
  }
  if( defined $HTDOC ) {
    $Depth--;
    $RLevel++;
    if( $HTDOC->field( Name => "Content-Type" ) eq "text/html" ) {
      my $HTML     = $HTDOC->body();
      my $Parser   = undef;
      if( $Simple->{Parser} eq "simple" ) {
  $Parser = NetSoup::HTML::Parser::Simple->new();
      } else {
  $Parser = NetSoup::HTML::Parser::Neanderthal->new();
      }
      my $Document = $Parser->parse( XML => \$HTML );
      $Simple->{History}->{$args{URL}} = 1;
      if( &$Callback( URL      => $args{URL},                                # Spider this document
          Document => $HTDOC ) ) {
  if( $Images ) {
  IMAGES: foreach my $anchor ( $Document->images() ) {
      next IMAGES if( ! $Simple->filter( URL => $anchor ) );
      my $hostname = $URLParse->hostname( $anchor );
      my $pathname = $URLParse->pathname( $anchor );
      my $filename = $URLParse->filename( $anchor );
      if( $pathname =~ m:^/: ) {
        $anchor = "$PROTOCOL://$HOSTNAME$pathname$filename";             # Absolute pathname
      } else {
        $anchor = "$PROTOCOL://$HOSTNAME$PATHNAME$pathname$filename";    # Relative pathname
      }
      if( ! exists $Simple->{History}->{$anchor} ) {
        $Simple->spider( URL      => $anchor,
             Depth    => $Depth,
             RLevel   => $RLevel,
             Callback => $Callback );
        $Simple->{History}->{$anchor} = 1;
      }
    }
  }
      ANCHOR: foreach my $anchor ( $Document->links() ) {
    next ANCHOR if( ! $Simple->filter( URL => $anchor ) );
    my $hostname = $URLParse->hostname( $anchor );
    my $pathname = $URLParse->pathname( $anchor );
    my $filename = $URLParse->filename( $anchor );
    if( ( length( $hostname ) > 0 ) && ( $HOSTNAME ne $hostname ) ) {  # Stay on same host
      print( "  " x $RLevel . qq(Skipping "$args{URL}"\n) );
      next ANCHOR;
    }
    if( $pathname =~ m:^/: ) {
      $anchor = "$PROTOCOL://$HOSTNAME$pathname$filename";             # Absolute pathname
    } else {
      $anchor = "$PROTOCOL://$HOSTNAME$PATHNAME$pathname$filename";    # Relative pathname
    }
    if( ! exists $Simple->{History}->{$anchor} ) {
      $Simple->spider( URL      => $anchor,
           Depth    => $Depth,
           RLevel   => $RLevel,
           Callback => $Callback ) if( $Depth > 0 );
      $Simple->{History}->{$anchor} = 1;
    }
  }
      }
    } else {
      &$Callback( URL      => $args{URL},
      Document => $HTDOC );
    }
  } else {
    print( qq(Error Fetching: "$args{URL}"\n) );
  }
  return(1);
}


sub filter {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    Spider
  #    hash    {
  #              URL => $URL
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Simple = shift;
  my %args   = @_;
 SWITCH: for( $args{URL} ) {
    m/^(ftp|javascript|mailto|nntp):/i && do {
      return(0);
    };
  }
  return(1);
}
