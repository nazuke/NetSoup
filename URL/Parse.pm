#!/usr/local/bin/perl
#
#   NetSoup::URL::Parse.pm v00.00.02b 12042000
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
#   Description: This Perl 5.0 class provides object methods for URL parsing.
#
#
#   Methods:
#       parse     -  This method parses a network address
#       AUTOLOAD  -  This method dispatches the call to the required URL component


package NetSoup::URL::Parse;
use strict;
use vars qw( $AUTOLOAD );
use NetSoup::Core;
use NetSoup::Files::Pathnames;
@NetSoup::URL::Parse::ISA = qw( NetSoup::Core );
my $PATHNAMES = NetSoup::Files::Pathnames->new();
1;


sub parse {
  # This method parses a network address, currently only the HTTP protocol is supported.
  # The parsed address is returned as a hash.
  # Calls:
  #    $PATHNAMES->resolve()
  # Parameters Required:
  #    object
  #    hash    {
  #              URL => $url
  #              Ref => \%hash
  #            }
  # Result Returned:
  #    boolean
  my $Parse       = shift;                                         # Get object
  my %args      = @_;                                            # Get arguments
  my ( $proto,
       $host,
       $port,
       $path,
       $file,
       $query ) = ( "", "", "", "", "", "" );
  if( $args{URL} =~ m/^http:/i ) {
    my $url   = $args{URL} || return(0);
    my @chars = split( //, $url );
    my %state = ( Protocol => 1,
                  Hostname => 0,
                  Pathname => 0,
                  Filename => 0,
                  Query    => 0 );
    for ( my $i = 0 ; $i <= ( @chars - 1 ) ; $i++ ) {
    SWITCH: for( $chars[$i] ) {
        m/:/ && do {
          if( $state{Protocol} ) {
            if( $chars[$i+1] . $chars[$i+2] eq "//" ) {
              $state{Protocol} = 0;
              $state{Hostname} = 1;
              $i              += 2;
              last SWITCH;
            }
          }
          if( $state{Hostname} ) {
            $state{Hostname} = 0;
            $state{Pathname} = 1;
          PORT: for( $i = $i ; $i <= ( @chars - 1 ) ; $i++ ) {
              last PORT if( $chars[$i+1] =~ m/[^0-9]/ );
              $port .= $chars[$i+1];
            }
            last SWITCH;
          }
        };
        m/\// && do {
          if( $state{Hostname} ) {
            $state{Hostname} = 0;
            $state{Pathname} = 1;
            redo SWITCH;
          }
          if( $state{Pathname} ) {
            my $flag = 1;
          PEEK: for( my $j = $i+1 ; $j <= ( @chars - 1 ) ; $j++ ) {
              if( $chars[$j] =~ m:[?/]: ) {
                $flag = 0;
                last PEEK;
              }
            }
            if( $flag ) {
              $state{Pathname} = 0;
              $state{Filename} = 1;
              $path           .= $chars[$i];
              last SWITCH;
            }
          }
        };
        m/\?/ && do {
          if( $state{Filename} ) {
            $state{Filename} = 0;
            $state{Query}    = 1;
            $query          .= $chars[$i];
            last SWITCH;
          }
        };
        m/./ && do {
          if( $state{Protocol} ) {
            $proto .= $chars[$i];
            last SWITCH;
          }
          if( $state{Hostname} ) {
            $host .= $chars[$i];
            last SWITCH;
          }
          if( $state{Pathname} ) {
            $path .= $chars[$i];
            last SWITCH;
          }
          if( $state{Filename} ) {
            $file .= $chars[$i];
            last SWITCH;
          }
          if( $state{Query} ) {
            $query .= $chars[$i];
            last SWITCH;
          }
          last SWITCH;
        };
      }
    }
  } else {
    my $url   = reverse( $args{URL} ) || return(0);            # Get reversed URL
    my @chars = split( //, $url );
    my %state = ( Query    => 0,
                  Filename => 1,
                  Pathname => 0,
                  Hostname => 0,
                  Protocol => 0 );
    if ( $url =~ m/\?/ ) {
      $state{Query}    = 1;
      $state{Filename} = 0;
    }
    for ( my $i = 0 ; $i <= ( @chars - 1 ) ; $i++ ) {
    SWITCH: for( $chars[$i] ) {
        m/\#/ && ( $state{Filename} == 1 ) && do {
          $file = "";
          last SWITCH;
        };
        m/\?/ && do {
          $state{Query}    = 0;
          $state{Filename} = 1;
          last SWITCH;
        };
        m|/| && do {
          if ( $state{Query} ) {
            $query = $chars[$i] . $query;
            last SWITCH;
          }
          if ( $state{Filename} ) {
            $state{Filename} = 0;
            $state{Pathname} = 1;
          }
          if ( $state{Pathname} ) {
            $path = $chars[$i] . $path;
            for ( my $j = $i + 1 ; $j <= ( @chars - 2 ) ; $j++ ) { #
              if ( $chars[$j] eq "/" ) {
                if ( $chars[$j+1] eq "/" ) {
                  $state{Pathname} = 0;
                  $state{Hostname} = 1;
                } else {
                  last SWITCH;
                }
              }
            }
            last SWITCH;
          }
          if ( $state{Hostname} ) {
            $state{Hostname} = 0;
            $state{Protocol} = 1;
            last SWITCH;
          }
          if ( $state{Protocol} ) {
            last SWITCH;
          }
        };
        m/:/ && do {
          if ( $state{Query} ) {
            $query = $chars[$i] . $query;
            last SWITCH;
          }
          if ( $state{Hostname} ) {
            $state{Hostname} = 0;
            $state{Protocol} = 1;
            last SWITCH;
          }
          if ( $state{Protocol} ) {
            last SWITCH;
          }
        };
        m|[^/]| && do {
          if ( $state{Query} ) {
            $query = $chars[$i] . $query;
            last SWITCH;
          }
          if ( $state{Filename} ) {
            $file = $chars[$i] . $file;
            last SWITCH;
          }
          if ( $state{Pathname} ) {
            $path = $chars[$i] . $path;
            last SWITCH;
          }
          if ( $state{Hostname} ) {
            $host = $chars[$i] . $host;
            last SWITCH;
          }
          if ( $state{Protocol} ) {
            $proto = $chars[$i] . $proto;
            last SWITCH;
          }
        };
      }
    }
  }
  if( ( $path eq "" ) && ( $file eq "" ) ) {
    $path = "/";
  }
  $path         =~ s:/?([^/]+)/\.\./:/:g;                         # Collapse relative path
  $path         =~ s:(/?)\./([^/]+):$1$2:g;                      # Collapse this directory path
  %{$args{Ref}} = ( Protocol => $proto || "http",
                    Hostname => $host,
                    Port     => $port  || 80,
                    Pathname => $path,
                    Filename => $file,
                    Query    => $query,
                    Resolved => "$proto://$host$path$file" );    #
  return(1);
}


sub AUTOLOAD {
  # This method dispatches the call to the required URL component.
  # The $AUTOLOAD variable is interrogated to determine which
  # object property to return.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    scalar
  # Result Returned:
  #    scalar
  # Example:
  #    my $protocol = $Parse->protocol( $url );
  #    my $hostname = $Parse->hostname( $url );
  #    my $port     = $Parse->port( $url );
  #    my $pathname = $Parse->pathname( $url );
  #    my $filename = $Parse->filename( $url );
  #    my $query    = $Parse->query( $url );
  my $Parse      = shift;
  my $url        = shift;
  my ( $method ) = ( $AUTOLOAD =~ m/::([^:]+$)/ );
  my %hash       = ();
  $Parse->parse( URL => $url, Ref => \%hash );
  return( $hash{ucfirst($method)} );
}
