#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::Element.pm v00.00.01z 12042000
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


package NetSoup::XML::DOM2::Core::Element;
use strict;
use NetSoup::Core;
use NetSoup::XML::DOM2::Core::Node;
use NetSoup::XML::DOM2::Core::NodeList;
use NetSoup::XML::DOM2::Core::Attr;
use NetSoup::XML::DOM2::Traversal::TreeWalker;
@NetSoup::XML::DOM2::Core::Element::ISA = qw( NetSoup::XML::DOM2::Core::Node );
my $MODULE     = "Element";
my $NODE       = "NetSoup::XML::DOM2::Core::Node";
my $ATTR       = "NetSoup::XML::DOM2::Core::Attr";
my $NODELIST   = "NetSoup::XML::DOM2::Core::NodeList";
my $TREEWALKER = "NetSoup::XML::DOM2::Traversal::TreeWalker";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NodeName  => $nodeName
  #              NodeValue => $nodeValue
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Element = NetSoup::XML::DOM2::Core::Element->new( NodeName => $nodeName, NodeValue => $nodeValue );
  my $Element                   = shift;                   # Get Element object
  my %args                      = @_;                      # Get arguments
  $Element->SUPER::initialise( %args );                    # Perform base class initialisation
  $Element->{Node}->{NodeType}  = "ELEMENT_NODE";          # Set node type
  $Element->{Node}->{NodeValue} = $args{NodeValue} || "";  # Get XML tag value
  $Element->{Node}->{TagName}   = $args{NodeName}  || "";  # Set XML tag name
  return( $Element );                                      # Return blessed Element object
}


sub getAttribute {
  # This method returns an attribute value string.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name   => $name
  #              nsNBSP => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $DOMString = $Element->getAttribute( Name => $name );
  my $Element = shift;                                                          # Get Element object
  my %args    = @_;                                                             # Get arguments
  my $name    = $args{Name};                                                    # Get attribute name
  my $nsNBSP  = $args{nsNBSP} || 0;                                             # True converts spaces to &nbsp;
  my $Node    = $Element->{Node}->{Attributes}->getNamedItem( Name => $name );  # Get attribute Node object
  if( defined $Node ) {                                                         # Check for named item
    if( $nsNBSP ) {
      my $value = $Node->nodeValue();
      $value    =~ s/ /\&nbsp;/gs;
      return( $value );
    } else {
      return( $Node->nodeValue() );                                             # Return DOMString value
    }
  }
  return( "" );
}


sub setAttribute {
  # This method creates a new attribute/value pair.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name  => $name
  #              Value => $value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Element->setAttribute( Name => $name, Value => $value );
  my $Element = shift;                                            # Get Element object
  my %args    = @_;                                               # Get arguments
  my $Node    = $NODE->new( NodeName  => $args{Name},             # Get new attribute node object
                            NodeValue => $args{Value},
                            NodeType  => "ATTRIBUTE_NODE" );
  $Element->{Node}->{Attributes}->setNamedItem( Node => $Node );  # Add new attribute node object
  return(1);
}


sub removeAttribute {
  # This method removes an attribute.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Element->removeAttribute( Name => $name );
  my $Element = shift;                                                     # Get Element object
  my %args    = @_;                                                        # Get arguments
  $Element->{Node}->{Attributes}->removeNamedItem( Name => $args{Name} );  # Remove named attribute
  return(1);
}


sub getAttributeNode {
  # This method returns an Attr object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Attr = $Element->getAttributeNode( Name => $name );
  my $Element = shift;                                                                      # Get Element object
  my %args    = @_;                                                                         # Get arguments
  my $Attr    = $ATTR->new( Name         => $args{Name},                                    # Get new Attr node object
                            Specified    => 0,
                            Value        => $Element->getAttribute( Name => $args{Name} ),
                            OwnerElement => $Element );
  return(1);
}


sub getElementsByTagName {
  # This method returns a NodeList. The name parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              TagName => $tagName
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $NodeList = $Element->getElementsByTagName( TagName => $tagName );
  my $Element  = shift;                                            # Get Element
  my %args     = @_;                                               # Get arguments
  my $TagName  = $args{TagName};
  my $NodeList = $NODELIST->new();
  my $TW       = $TREEWALKER->new( Filter => sub { return(1) } );  # Create TreeWalker object
  $TW->walkTree( Node     => $Element,                             # Walk Element tree building NodeList of Nodes
                 Callback => sub {
                   my $Node = shift;
                   if( $Node->nodeName() eq $TagName ) {
                     $NodeList->appendNode( Node => $Node );
                   }
                   return(1);
                 } );
  return( $NodeList );                                             # Return NodeList object
}


sub getElementsByTagNameNS {
  # This method returns a NodeList. The namespaceURI parameter is of type DOMString. The localName parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NamespaceURI => $namespaceURI
  #              LocalName    => $localName
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $NodeList = $Element->getElementsByTagNameNS( NamespaceURI => $namespaceURI, LocalName => $localName );
  my $Element      = shift;                                            # Get Element
  my %args         = @_;                                               # Get arguments
  my $NamespaceURI = $args{NamespaceURI};
  my $LocalName    = $args{LocalName};
  my $NodeList     = $NODELIST->new();
  my $TW           = $TREEWALKER->new( Filter => sub { return(1) } );  # Create TreeWalker object
  $TW->walkTree( Node     => $Element,                                 # Walk Element tree building NodeList of Nodes
                 Callback => sub {
                   my $Node = shift;
                   if( ( $Node->namespaceURI() eq $NamespaceURI ) &&
                       ( $Node->nodeName()     eq $LocalName ) ) {
                     $NodeList->appendNode( Node => $Node );
                   }
                   return(1);
                 } );
  return( $NodeList );                                                 # Return NodeList object
}


sub getAttributeNS {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method returns a DOMString. The namespaceURI parameter is of type DOMString. The localName parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NamespaceURI => $namespaceURI
  #              LocalName    => $localName
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Attr = $Element->getElementsByTagName( Name => $name );
  my $Element = shift;                                    # Get Element object
  my %args    = @_;                                       # Get arguments
  my $name    = $args{Name};                              # Get attribute name
  my $value   = $Element->getAttribute( Name => $name );  # Get attribute value
  my $Attr    = $ATTR->new( Name         => $name,        # Get new Attr node object
                            Specified    => 0,
                            Value        => $value,
                            OwnerElement => $Element );
  return(1);
}


sub setAttributeNS {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method returns a void. The namespaceURI parameter is of type DOMString. The qualifiedName parameter is of type DOMString. The value parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              namespaceURI => $namespaceURI
  #              qualifiedName    => $qualifiedName
  #              value    => $value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Attr = $Element->getElementsByTagName( Name => $name );
  my $Element = shift;                                    # Get Element object
  my %args    = @_;                                       # Get arguments
  my $name    = $args{Name};                              # Get attribute name
  my $value   = $Element->getAttribute( Name => $name );  # Get attribute value
  my $Attr    = $ATTR->new( Name         => $name,        # Get new Attr node object
                            Specified    => 0,
                            Value        => $value,
                            OwnerElement => $Element );
  return(1);
}


sub removeAttributeNS {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method returns a void. The namespaceURI parameter is of type DOMString. The localName parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              namespaceURI => $namespaceURI
  #              localName    => $localName
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Attr = $Element->getElementsByTagName( Name => $name );
  my $Element = shift;                                    # Get Element object
  my %args    = @_;                                       # Get arguments
  my $name    = $args{Name};                              # Get attribute name
  my $value   = $Element->getAttribute( Name => $name );  # Get attribute value
  my $Attr    = $ATTR->new( Name         => $name,        # Get new Attr node object
                            Specified    => 0,
                            Value        => $value,
                            OwnerElement => $Element );
  return(1);
}


sub getAttributeNodeNS {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method returns a Attr. The namespaceURI parameter is of type DOMString. The localName parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              namespaceURI => $namespaceURI
  #              localName    => $localName
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Attr = $Element->getElementsByTagName( Name => $name );
  my $Element = shift;                                    # Get Element object
  my %args    = @_;                                       # Get arguments
  my $name    = $args{Name};                              # Get attribute name
  my $value   = $Element->getAttribute( Name => $name );  # Get attribute value
  my $Attr    = $ATTR->new( Name         => $name,        # Get new Attr node object
                            Specified    => 0,
                            Value        => $value,
                            OwnerElement => $Element );
  return(1);
}


sub setAttributeNodeNS {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method returns a Attr. The newAttr parameter is of type Attr.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              newAttr => $newAttr
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Attr = $Element->getElementsByTagName( Name => $name );
  my $Element = shift;                                    # Get Element object
  my %args    = @_;                                       # Get arguments
  my $name    = $args{Name};                              # Get attribute name
  my $value   = $Element->getAttribute( Name => $name );  # Get attribute value
  my $Attr    = $ATTR->new( Name         => $name,        # Get new Attr node object
                            Specified    => 0,
                            Value        => $value,
                            OwnerElement => $Element );
  return(1);
}
