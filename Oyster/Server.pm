#!/usr/local/bin/perl
#
#   NetSoup::Oyster::Document.pm v00.00.01a 12042000
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


package NetSoup::Oyster::Server;
use strict;
use POSIX;
use Getopt::Std;
use NetSoup::Core;
use NetSoup::Protocol;
use NetSoup::Protocol::HTTP::Document;
use NetSoup::Oyster::Executor;
@NetSoup::Oyster::Server::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Server          = shift;          # Get object
  my %args            = @_;             # Get arguments
  my %OPTIONS         = ();
  $Server->{Defaults} = { ConfigFile   => "",    #
                          Port         => 8080,
                          ServerRoot   => "",
                          DocumentRoot => "" };  #
  $Server->{Types}    = { "html" => "text/html",
                          "pxml" => "text/html" };
  ( $Server->{Defaults}->{ConfigFile} ) = ( $0 =~ m/^(.+\/)[^\/]+$/ );
  $Server->{Defaults}->{ConfigFile}    .= "../conf/oysterd.conf";
  getopt( "fd", \%OPTIONS );
  $Server->{Defaults}->{ConfigFile} = $OPTIONS{f} if( $OPTIONS{f} );
  $Server->{Defaults}->{ServerRoot} = $OPTIONS{d} if( $OPTIONS{d} );
  if( -e $Server->{Defaults}->{ConfigFile} ) {
    $Server->readConfig();
  } else {
    print( STDERR qq(Config File "$Server->{Defaults}->{ConfigFile}" Not Found\n) );
    exit(-1);
  }
  return( $Server );
}


sub readConfig {
  my $Server   = shift;          # Get object
  my %args     = @_;             # Get arguments
  my $filename = $Server->{Defaults}->{ConfigFile};
  if( open( CONFIG, $filename ) ) {
    my @config = <CONFIG>;
    close( CONFIG );
    for( my $i = 0 ; $i < @config ; $i++ ) {
      my $line = $config[$i];
    OPTION: for( $line ) {
        m/^[ \t]*\#/i && do {
          last OPTION;
        };
        m/^ServerRoot/i && do {
          ( $Server->{Defaults}->{ServerRoot} ) = ( $line =~ m/^[ \t]*ServerRoot[ \t]+\"([^\"]+)\"/i );
          last OPTION;
        };
        m/^Port/i && do {
          ( $Server->{Defaults}->{Port} ) = ( $line =~ m/^[ \t]*Port[^\d]+(\d+)/i );
          last OPTION;
        };
        m/^DocumentRoot/i && do {
          ( $Server->{Defaults}->{DocumentRoot} ) = ( $line =~ m/^[ \t]*DocumentRoot[ \t]+\"([^\"]+)\"/i );
          last OPTION;
        };
      }
    }
  } else {
    print( STDERR qq(Config File "$Server->{Defaults}->{ConfigFile}" Not Found\n) );
    exit(-1);
  }
  return(1);
}


sub run {
  my $Server   = shift;          # Get object
  my %args     = @_;             # Get arguments
  my $Protocol = NetSoup::Protocol->new();
  if ( $Protocol->server( Port => $Server->{Defaults}->{Port} ) ) {
    my $QUIT = 0;
    print( STDERR "Oyster Ready\n" );
    $Protocol->loop( Args     => {},
                      Fork     => 0,
                      Quit     => \$QUIT,
                      Callback => sub {
                       $Server->request( Protocol => $Protocol );
                     } );
  } else {
    print( STDERR "Server Initialisation Failed\n" );
  }
  return(1);
}


sub request {
  my $Server   = shift;          # Get object
  my %args     = @_;             # Get arguments
  my $Protocol = $args{Protocol};
  my $Request  = "";
  my $HTDOC    = NetSoup::Protocol::HTTP::Document->new();
 REQUEST: while() {
    my $char = "";
    $Protocol->get( Data => \$char, Length => 1 );
    $Request .= $char;
    last REQUEST if( $Request =~ m/\r\n\r\n$/s );
  }
  $HTDOC->head( Head => \$Request );
 METHOD: for( $HTDOC->method() ) {
    m/^GET$/i && do {
      my $Path     = $HTDOC->path();
      $Path        =~ s/^\///;
      $Path        = $Server->{Defaults}->{DocumentRoot} . "/" . $Path;
      my $Response = $Server->get_execute( Path => $Path );
      $Protocol->put( Data => \$Response );
      last METHOD;
    };
  }
  return(1);
}


sub get_execute {
  my $Server     = shift;          # Get object
  my %args       = @_;             # Get arguments
  my $Response   = "";
  print( STDERR qq(Path: "$args{Path}"\n) );
  if( ( -e $args{Path} ) && ( open( DOC, $args{Path} ) ) ) {
    my $Executor = NetSoup::Oyster::Executor->new();
    my $XML      = join( "", <DOC> );
    #my $HTML    = $Executor->execute( XML => \$XML );
    

    my $execbin  = $Server->{Defaults}->{ServerRoot} . "/bin/executor";
    my $HTML     = `$execbin $args{Path}`;


    $Response   .= "HTTP/1.0 200 OK\r\n";
    $Response   .= "Content-Type: text/html\r\n";
    $Response   .= "Connection: close\r\n";
    $Response   .= "Content-length: " . length( $HTML ) . "\r\n";
    $Response   .= "\r\n";
    $Response   .= $HTML;
    close( DOC );
  } else {
    $Response .= "HTTP/1.0 400 Bad Request\r\n";
    $Response .= "Content-Type: text/html\r\n";
    $Response .= "\r\n";
    $Response .= "<h1>File Not Found</h1>";
  }
  return( $Response );
}
