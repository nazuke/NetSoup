#!/usr/local/bin/perl
#
#   NetSoup::Protocol::GTP::Client.pm v00.00.01a 12042000
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


package NetSoup::Protocol::GTP::Client;
use strict;
use NetSoup::Protocol;
use NetSoup::Protocol::GTP;
@NetSoup::Protocol::GTP::Client::ISA = qw( NetSoup::Protocol::GTP );
1;


sub lookup {
  # Description.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              SourceLang => $sourceLang
  #              TargetLang => $targetLang
  #              Strings    => \%hash
  #              Overwrite  => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object  = shift;                                                 # Get object
  my %args    = @_;                                                    # Get arguments
  my $address = $object->getConfig( Key => "GlotServAddr" );           # Get NetSoup glossary server address constant
  my $port    = $object->getConfig( Key => "GlotServPort" );           # Get NetSoup glossary port number constant
  my $socket  = NetSoup::Protocol->new();                              # Get new socket protocol object
  my @request = ();                                                    # Array holds request data
  my $request = "";                                                    # Will contain composed request
  my $newline = "\x0D\x0A";                                            # Line ending sequence
  my $data    = "";
  push( @request, "SourceLang: " . $args{SourceLang} );                # Source language header
  push( @request, "TargetLang: " . $args{TargetLang} );                # Target language header
  push( @request, "Overwrite: "  . $args{Overwrite} );                 # String overwrite header
  push( @request, "" );                                                # Header terminator
 BODY: foreach my $key ( keys %{$args{Strings}} ) {                    # Compose body content
    push( @request, join( "\t", $key, $args{Strings}->{$key} ) );
  }
  foreach my $line ( @request ) { $request .= "$line$newline" }
  my $cntLength = "Content-length: " . length($request) . "$newline";  # Compose content length header
  # Send Server Request
  $socket->client( Address => $address, Port => $port );               # Put object into client mode
  $socket->put( Data => \$cntLength );                                 # Send content length
  $socket->put( Data => \$request );                                   # Send request data
  # Read Server Reply
  my $rLength = "";
 LENGTH: while() {                                                     # Fetch content length
    my $minibuf = "";
    $socket->get( Data => \$minibuf, Length => 1 );
    $rLength .= $minibuf;
    last LENGTH if( $rLength =~ m/\x0D\x0A$/gs );
  }
  ( $rLength ) = ( $rLength =~ m/^.+:[ \t]*(\d+)/s );                  # Extract content length
  $socket->get( Data => \$data, Length => $rLength );                  # Fetch remaining data
  # Sent reply back to calling program
  $object->parseBody( Data => \$data );                                # Parse received message
  %{$args{Strings}} = %{$object->{Pairs}};                             # Reinitialise strings hash
  $socket->disconnect();                                               # Close down sockect
  return(1);
}
