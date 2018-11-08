#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::DocumentType.pm v00.00.01b 12042000
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
#       initialise  -  This method is the object initialiser for this class


package NetSoup::XML::DOM2::Core::DocumentType;
use strict;
use NetSoup::XML::DOM2::Core::Node;
use NetSoup::XML::DOM2::Core::NamedNodeMap;
@NetSoup::XML::DOM2::Core::DocumentType::ISA = qw( NetSoup::XML::DOM2::Core::Node );
my $MODULE       = "DocumentType";
my $NAMEDNODEMAP = "NetSoup::XML::DOM2::Core::NamedNodeMap";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              NodeValue => $nodeValue
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $DocumentType = NetSoup::XML::DOM2::Core::DocumentType->new();
  my $DocumentType                        = shift;                                          # Get DocumentType object
  my %args                                = @_;                                             # Get arguments
  $DocumentType->SUPER::initialise( %args );                                                # Perform base class initialisation
  $DocumentType->{Node}->{NodeName}       = "DOCTYPE";                                      # Set Node name
  $DocumentType->{Node}->{NodeType}       = "DOCUMENT_TYPE_NODE";                           # Set Node type
  $DocumentType->{Node}->{Root}           = $args{Root}           || "";                    # Set Document root
  $DocumentType->{Node}->{Name}           = $args{Name}           || "";                    # Set character data value
  $DocumentType->{Node}->{Entities}       = $args{Entities}       || $NAMEDNODEMAP->new();  # Set XML tag name
  $DocumentType->{Node}->{Notations}      = $args{Notations}      || $NAMEDNODEMAP->new();  # Set character data value
  $DocumentType->{Node}->{PublicID}       = $args{PublicID}       || "";                    # Set character data value
  $DocumentType->{Node}->{SystemID}       = $args{SystemID}       || "";                    # Set character data value
  $DocumentType->{Node}->{InternalSubset} = $args{InternalSubset} || "";                    # Set character data value
  $DocumentType->{NetSoup}->{Root}        = $args{Root}           || "";                    # Set name of root Node
  $DocumentType->{NetSoup}->{URI}         = $args{URI}            || "";                    # Set URI of DTD document

  $DocumentType->{NetSoup}->{Element}     = $NAMEDNODEMAP->new();                           # List of DTD Element objects
  $DocumentType->{NetSoup}->{Attlist}     = $NAMEDNODEMAP->new();                           # List of DTD Attlist objects

  return( $DocumentType );                                                                  # Return blessed DocumentType object
}


sub publicID {
  # This method gets/sets the node's URI property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              PublicID => $PublicID
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $PublicID = $DocumentType->publicID( PublicID => $PublicID );
  my $DocumentType = shift;                               # Get object
  my %args         = @_;                                  # Get arguments
  if( exists $args{PublicID} ) {
    $DocumentType->{Node}->{PublicID} = $args{PublicID};  # Set PublicID
  }
  return( $DocumentType->{Node}->{PublicID} );
}


sub systemID {
  # This method gets/sets the node's URI property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              SystemID => $SystemID
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $SystemID = $DocumentType->systemID( SystemID => $SystemID );
  my $DocumentType = shift;                               # Get object
  my %args         = @_;                                  # Get arguments
  if( exists $args{SystemID} ) {
    $DocumentType->{Node}->{SystemID} = $args{SystemID};  # Set SystemID
  }
  return( $DocumentType->{Node}->{SystemID} );
}


sub root {
  # This method gets/sets the node's URI property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Root => $Root
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $Root = $DocumentType->systemID( Root => $Root );
  my $DocumentType = shift;                       # Get object
  my %args         = @_;                          # Get arguments
  if( exists $args{Root} ) {
    $DocumentType->{Node}->{Root} = $args{Root};  # Set Root
  }
  return( $DocumentType->{Node}->{Root} );
}


sub URI {
  # This method gets/sets the node's URI property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              URI => $URI
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $URI = $DocumentType->URI( URI => $URI );
  my $DocumentType = shift;                        # Get object
  my %args         = @_;                           # Get arguments
  if( exists $args{URI} ) {
    $DocumentType->{NetSoup}->{URI} = $args{URI};  # Set NodeName
  }
  return( $DocumentType->{NetSoup}->{URI} );
}
