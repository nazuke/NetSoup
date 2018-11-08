#!/usr/local/bin/perl
#
#   NetSoup::Autonomy::DRE::Query::Burst.pm v00.00.01a 12042000
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


package NetSoup::Autonomy::DRE::Query::Burst;
use strict;
use Digest::MD5;
use NetSoup::Autonomy::DRE::Query::HTTP;
use NetSoup::Encoding::Hex;
use NetSoup::Files;
use NetSoup::Protocol::HTTP;
use constant HEX => NetSoup::Encoding::Hex->new();
@NetSoup::Autonomy::DRE::Query::Burst::ISA = qw( NetSoup::Autonomy::DRE::Query::HTTP );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Caching  => 0 | 1
  #              Period   => time
  #              Hostname => $hostname
  #              Port     => 0 .. 65535
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Burst         = shift;           # Get DRE Query object
  my %args          = @_;              # Get arguments
  $Burst->{Objects} = {};
  $Burst->{Queries} = {};
  $Burst->SUPER::initialise( %args );  # Initialise base class
  return( $Burst );
}


sub mquery_client {
  # This method performs a series of queries against an array.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              QMethod   => $QMethod
  #              QueryText => $QueryText
  #              QNum      => $QNum
  #              Database  => $Database
  #              XOptions  => $XOptions
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Burst = shift;                   # Get DRE Query object
  my %args  = @_;                        # Get arguments
  foreach my $querytext ( @{$args{Queries}} ) {
    
#    $Burst->
      
  }
}


sub mquery_server {
  # This method performs a series of queries against an array.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              QMethod   => $QMethod
  #              QueryText => $QueryText
  #              QNum      => $QNum
  #              Database  => $Database
  #              XOptions  => $XOptions
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Burst = shift;                   # Get DRE Query object
  my %args  = @_;                        # Get arguments
  foreach my $querytext ( @{$args{Queries}} ) {
    $Burst->{Objects}->{$querytext} = NetSoup::Autonomy::DRE::Query::HTTP->new( Caching  => $Burst->{Caching},
                                                                       Period   => $Burst->{Period},
                                                                       Hostname => $Burst->{Hostname},
                                                                       Port     => $Burst->{Port} );
    $Burst->{Objects}->{$querytext}->query( QueryText => $querytext,
                                            QNum      => $args{QNum},
                                            Database  => $args{Database} );
    $Burst->{Queries}->{$querytext} = $Burst->{TResult};
  }
  return( $Burst );
}


sub numhits {
  my $Burst = shift;                                       # Get DRE Query object
  my %args  = @_;                                          # Get arguments
  return( $Burst->{Objects}->{$args{Query}}->numhits() );  #
}


sub fieldnames {
  my $Burst = shift;                                          # Get DRE Query object
  my %args  = @_;                                             # Get arguments
  return( $Burst->{Objects}->{$args{Query}}->fieldnames() );  #
}


sub field {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Index => $index
  #              Field => $field
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Burst = shift;                                                 # Get DRE Query object
  my %args  = @_;                                                    # Get arguments
  return( $Burst->{Objects}->{$args{Query}}->fieldnames( %args ) );  #
}


sub packet {
  my $Burst  = shift;                                               # Get DRE Query object
  my %args   = @_;                                                  # Get arguments
  my $packet = "";
  foreach my $key ( keys %{$Burst->{Queries}} ) {
    $packet .= HEX->bin2hex( Data => $key ) . HEX->bin2hex( Data => $Burst->{Objects}->{$key}->tresult() ) . "\n";
  }
  return( $packet );
}


sub unpacket {
  my $Burst  = shift;                                               # Get DRE Query object
  my %args   = @_;                                                  # Get arguments
  my $packet = $args{Packet};
  foreach my $line ( split( /\n/, $packet ) ) {
    my ( $query, $result ) = split( /\t/, $line );
    $query  = HEX->hex2bin( Data => $query );
    $result = HEX->hex2bin( Data => $result );
    $Burst->{Objects}->{$query} = NetSoup::Autonomy::DRE::Query::HTTP->new( Caching  => $Burst->{Caching},
                                                                   Period   => $Burst->{Period},
                                                                   Hostname => $Burst->{Hostname},
                                                                   Port     => $Burst->{Port} );
    $Burst->parse( Result => $result );
  }
  return( $Burst );
}
