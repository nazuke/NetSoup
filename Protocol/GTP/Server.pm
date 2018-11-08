#!/usr/local/bin/perl
#
#   NetSoup::Protocol::GTP::Server.pm v00.00.01a 12042000
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
#       request  -  This method handles and processes an incoming client request
#       reply    -  This method composes and sends a reply to the client
#       sLookup  -  This method sends a lookup request to the glossary


package NetSoup::Protocol::GTP::Server;
use strict;
use NetSoup::Protocol::GTP;
use NetSoup::Text::Glossary;
@NetSoup::Protocol::GTP::Server::ISA = qw( NetSoup::Protocol::GTP );
1;


sub request {
  # This method handles and processes an incoming client request.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Socket    => $socket
  #              Overwrite => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object = shift;                                               # Get object
  my %args   = @_;                                                  # Get arguments
  my $data   = "";                                                  # Stores raw incoming data
  my $length = "";
  $object->initialise();                                            # Re-initialise object data members
 LENGTH: while() {                                                  # Fetch content length
    my $minibuf = "";
    $args{Socket}->get( Data => \$minibuf, Length => 1 );           #
    $length .= $minibuf;
    last LENGTH if( $length =~ m/\x0D\x0A$/gs );
  }
  ( $length ) = ( $length =~ m/^.+:[ \t]*(\d+)/s );                 # Extract content length
  $args{Socket}->get( Data => \$data, Length => $length );          # Fetch remaining data
  $object->parseMessage( Data => \$data );                          # Parse received message
  $object->sLookup( Overwrite => $object->{Header}->{Overwrite} );  # Query glossary database
  $object->reply( Socket => $args{Socket} );                        # Send reply
  $args{Socket}->disconnect();                                      # Close down sockect
  return(1);
}


sub reply {
  # This method composes and sends a reply to the client.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Socket  => $socket
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object  = shift;                                             # Get object
  my %args    = @_;                                                # Get arguments
  my $reply   = "";                                                # Contains reply data
  my $newline = "\x0D\x0A";                                        # Line ending sequence
  my $blank   = "";
  foreach my $ref ( @{$object->{Strings}} ) {                      # Compose body content
    $reply .= join( "\t", @{$ref} ) . $newline;                    # Construct line
  }
  my $cntLength = "Content-length: " . length($reply) . $newline;  # Compose content length header
  $args{Socket}->put( Data => \$cntLength );                       # Send content length
  $args{Socket}->put( Data => \$blank );                           # Send blank line
  $args{Socket}->put( Data => \$reply );                           # Send request data
  return(1);
}


sub sLookup {
  # This method sends a lookup request to the glossary.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Overwrite => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object    = shift;                                           # Get object
  my %args      = @_;                                              # Get arguments
  my $overwrite = $args{Overwrite} || 0;
  my $lookup    = NetSoup::Text::Glossary->new();
  my %source    = ();
  my @target    = ();
  foreach my $ref ( @{$object->{Strings}} ) {                      # Compose body content
    $source{$ref->[0]} = $ref->[1];                                # Load with source and target strings
  }
  $lookup->lookup( SourceLang => $object->{Header}->{SourceLang},  # Execute glossary database lookup
                   TargetLang => $object->{Header}->{TargetLang},
                   Strings    => \%source,
                   Overwrite  => $overwrite );
  foreach my $entry ( @{$object->{Strings}} ) {                    # Compose body content
    my ( $source, $target ) = @$entry;                             # Consolidate array components
    push( @target, [ $source, $source{$source} ] );                # Add string componentes to object
  }
  $object->{Strings} = \@target;                                   # Re-assign object member to array reference
  return(1);
}
