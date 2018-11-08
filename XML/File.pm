#!/usr/local/bin/perl
#
#   NetSoup::XML::File.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides some utility methods.
#
#   Methods:
#       load  -  This method loads an XML Document from a disk file


package NetSoup::XML::File;
use strict;
use NetSoup::Core;
use NetSoup::Files::Load;
use NetSoup::Files::Save;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
@NetSoup::XML::File::ISA = qw( NetSoup::Core );
use constant LOAD => NetSoup::Files::Load->new();
use constant SAVE => NetSoup::Files::Save->new();
1;


sub load {
  # This method loads an XML Document from a disk file.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash    {
  #              Pathname => $pathname
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Document = $File->load( Pathname => $pathname );
  my $File     = shift;                                                 # Get File object
  my %args     = @_;                                                    # Get arguments
  my $Pathname = $args{Pathname} || return( undef );                    # Get pathname of XML document
  my $Parser   = NetSoup::XML::Parser->new( Debug => $File->{Debug} );
  my $XML      = LOAD->immediate( Pathname => $Pathname );
  return( $Parser->parse( XML => \$XML ) );
}


sub save {
  # This method saves an XML Document to a disk file.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash    {
  #              Document => $DOM2
  #              Pathname => $pathname
  #              Compact  => 0 | 1
  #              Beautify => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $XML = $File->save( Document => $DOM2, Pathname => $pathname );
  my $File     = shift;                                     # Get File object
  my %args     = @_;                                        # Get arguments
  my $Document = $args{Document} || return( undef );        # Get XML DOM2 object
  my $Pathname = $args{Pathname} || return( undef );        # Get pathname of XML document
  my $Compact  = $args{Compact}  || 0;
  my $Beautify = $args{Beautify} || 0;
  my $OmitPI   = $args{OmitPI}   || 0;
  my $XML      = $File->serialise( Document => $Document,
                                   OmitPI   => $OmitPI,
                                   Compact  => $Compact,
                                   Beautify => $Beautify );
  SAVE->save( Pathname => $Pathname, Data => \$XML );
  return( $XML );
}


sub qparse {
  # This method quickly parses a chunk of XML.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash    {
  #              XML => $XML
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Document = $File->qparse( XML => $XML );
  my $File   = shift;                                                 # Get File object
  my %args   = @_;                                                    # Get arguments
  my $XML    = $args{XML};
  my $Parser = NetSoup::XML::Parser->new( Debug => $File->{Debug} );
  return( $Parser->parse( XML => \$XML ) );
}


sub serialise {
  # This method serialises an XML Document to a scalar value.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash    {
  #              Document   => $DOM2
  #              StrictSGML => 0 | 1
  #              OmitPI     => 0 | 1
  #              Compact    => 0 | 1
  #              Beautify   => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $XML = $File->save( Document => $DOM2, Pathname => $pathname );
  my $File       = shift;                                                                          # Get File object
  my %args       = @_;                                                                             # Get arguments
  my $Document   = $args{Document}   || return( undef );                                             # Get XML DOM2 object
  my $StrictSGML = $args{StrictSGML} || 0;
  my $OmitPI     = $args{OmitPI}     || 0;
  my $Compact    = $args{Compact}    || 0;
  my $Beautify   = $args{Beautify}   || 0;
  my $XML        = "";
  my $DT         = NetSoup::XML::DOM2::Traversal::DocumentTraversal->new();
  $DT->createSerialise( WhatToShow               => undef,
                        Filter                   => sub { return(1) },
                        EntityReferenceExpansion => 0,
                        CurrentNode              => $Document,
                        StrictSGML               => $StrictSGML,
                        OmitPI                   => $OmitPI,
                        Compact                  => $Compact )->serialise( Node   => $Document,
                                                                           Target => \$XML );
  if( $Beautify ) {
    my $Parser = NetSoup::XML::Parser->new( Debug => $File->{Debug} );
    my $RAW    = $XML;
    $XML       = $File->serialise( Document   => $Parser->parse( XML => \$RAW ),
                                   StrictSGML => $args{StrictSGML},
                                   OmitPI     => $args{OmitPI} );
  }
  return( $XML );
}
