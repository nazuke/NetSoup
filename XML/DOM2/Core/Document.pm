#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::Document.pm v00.00.01z 12042000
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


package NetSoup::XML::DOM2::Core::Document;
use strict;
use NetSoup::Core;
use NetSoup::XML::DOM2::Core::DocumentFragment;
use NetSoup::XML::DOM2::Core::CDATASection;
use NetSoup::XML::DOM2::Core::Comment;
use NetSoup::XML::DOM2::Core::Element;
use NetSoup::XML::DOM2::Core::NodeList;
use NetSoup::XML::DOM2::Core::ProcessingInstruction;
use NetSoup::XML::DOM2::Core::Text;
use NetSoup::XML::DOM2::Traversal::TreeWalker;
@NetSoup::XML::DOM2::Core::Document::ISA = qw( NetSoup::XML::DOM2::Core::Element );
my $MODULE                = "Document";
my $FRAGMENT              = "NetSoup::XML::DOM2::Core::DocumentFragment";
my $CDATASECTION          = "NetSoup::XML::DOM2::Core::CDATASection";
my $COMMENT               = "NetSoup::XML::DOM2::Core::Comment";
my $ELEMENT               = "NetSoup::XML::DOM2::Core::Element";
my $NODELIST              = "NetSoup::XML::DOM2::Core::NodeList";
my $PROCESSINGINSTRUCTION = "NetSoup::XML::DOM2::Core::ProcessingInstruction";
my $TEXT                  = "NetSoup::XML::DOM2::Core::Text";
my $TREEWALKER            = "NetSoup::XML::DOM2::Traversal::TreeWalker";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Doctype         => $Doctype
  #              Implementation  => $Implementation
  #              DocumentElement => $DocumentElement
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Document = NetSoup::XML::DOM2::Core::Document->new( Name => $name );
  my $Document                         = shift;                               # Get Document object
  my %args                             = @_;                                  # Get arguments
  $Document->SUPER::initialise( %args );                                      # Perform base class initialisation
  $Document->{Node}->{NodeName}        = "root";                              # Document Node name
  $Document->{Node}->{NodeType}        = "DOCUMENT_NODE";                     # Node type
  $Document->{Node}->{ChildNodes}      = $NODELIST->new( _Name => $MODULE );  # Type NodeList
  $Document->{Node}->{Doctype}         = $args{Doctype}         || undef;     # Type DocumentType
  $Document->{Node}->{Implementation}  = $args{Implementation}  || undef;     # Type DOMImplementation
  $Document->{Node}->{DocumentElement} = $args{DocumentElement} || undef;     # Type Element
  $Document->{Node}->{Indent}          = 0;
  my $XML = $PROCESSINGINSTRUCTION->new( Target => "xml",                     # Create Processing Instruction object
                                         Data   => qq(version="1.0") );
  $Document->appendChild( NewChild => $XML );                                 # Append XML Processing Instruction to Document
  return( $Document );                                                        # Return Document object
}


sub createElement {
  # This method returns a Element.
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
  #    my $Element = $Document->new( TagName => $tagName );
  my $Document = shift;                                    # Get Document
  my %args     = @_;                                       # Get arguments
  return( $ELEMENT->new( NodeName      => $args{TagName},  # Get and return Element object
                         NodeValue     => "",
                         OwnerDocument => $Document ) );
}


sub createDocumentFragment {
  # This method returns a DocumentFragment.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  # Result Returned:
  #    $node
  # Example:
  #    my $DocumentFragment = $Document->createDocumentFragment();
  my $Document = shift;                                    # Get Document
  my %args     = @_;                                       # Get arguments
  return( $FRAGMENT->new( OwnerDocument => $Document ) );  # Get and return DocumentFragment object
}


sub createTextNode {
  # This method returns a Text.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => $data
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Text = $Document->createTextNode( Data => $data );
  my $Document = shift;                                # Get Document
  my %args     = @_;                                   # Get arguments
  return( $TEXT->new( NodeValue     => $args{Data},    # Get and return Text node
                      OwnerDocument => $Document ) );
}


sub createComment {
  # This method returns a Comment.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => $data
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Comment = $Document->createComment( Data => $data );
  my $Document = shift;                                   # Get Document
  my %args     = @_;                                      # Get arguments
  return( $COMMENT->new( NodeValue     => $args{Data},    # Get and return Comment node
                         OwnerDocument => $Document ) );
}


sub createCDATASection {
  # This method returns a CDATASection.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => $data
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $CDATASection = $Document->createCDATASection( Data => $data );
  my $Document = shift;                                        # Get Document
  my %args     = @_;                                           # Get arguments
  return( $CDATASECTION->new( NodeValue     => $args{Data},    # Get and return CDATASection node object
                              OwnerDocument => $Document ) );
}


sub createProcessingInstruction {
  # This method returns a ProcessingInstruction.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Target => $target
  #              Data   => $data
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $PI = $Document->createProcessingInstruction( Target => $target, Data => $data );
  my $Document = shift;                                                 # Get Document
  my %args     = @_;                                                    # Get arguments
  return( $PROCESSINGINSTRUCTION->new( Target        => $args{Target},  # Get and return ProcessingInstruction object
                                       Data          => $args{Data},
                                       OwnerDocument => $Document ) );
}


sub createAttribute {
  # This method returns a Attr.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Attribute = $Document->createAttribute( Name => $name );
  my $Document  = shift;        # Get Document
  my %args      = @_;           # Get arguments
  my $name      = $args{Name};  #
  my $Attribute = undef;        # UNIMPLEMENTED
  return( $Attribute );         # Return Attribute node object
}


sub createEntityReference {
  # This method returns a EntityReference. The name parameter is of type DOMString.
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $EntityReference = $Document->createEntityReference( Name => $name );
  my $Document        = shift;        # Get Document
  my %args            = @_;           # Get arguments
  my $name            = $args{Name};  #
  my $EntityReference = undef;        # UNIMPLEMENTED
  return( $EntityReference );         # Return EntityReference node object
}


sub getElementById {
  # This method returns a Element. The elementId parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              ElementId => $elementId
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Element = $Document->getElementById( ElementId => $elementId );
  my $Document = shift;                                            # Get Document
  my %args     = @_;                                               # Get arguments
  my $ElementId  = $args{ElementId};
  my $Element  = undef;
  my $TW       = $TREEWALKER->new( Filter => sub { return(1) } );  # Create TreeWalker object
  $TW->walkTree( Node     => $Document,                            # Walk Document tree building NodeList of Nodes
                 Callback => sub {
                   my $Node = shift;
                   if( ( $Node->nodeType() eq "ELEMENT_NODE" ) &&
                       ( $Node->getAttribute( Name => "id" ) eq $ElementId ) ) {
                     $Element = $Node;
                     return( undef );
                   }
                   return(1);
                 } );
  return( $Element );                                             # Return NodeList object
}


sub getElementsByTagName {
  # This method returns a NodeList. The tagname parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              TagName => $tagName
  #            }
  # Result Returned:
  #    $NodeList
  # Example:
  #    my $NodeList = $Document->getElementsByTagName( TagName => $tagName );
  my $Document = shift;                                            # Get Document
  my %args     = @_;                                               # Get arguments
  my $TagName  = $args{TagName};
  my $NodeList = $NODELIST->new();
  my $TW       = $TREEWALKER->new( xFilter => sub { return(1) } );  # Create TreeWalker object
  $TW->walkTree( Node     => $Document,                            # Walk Document tree building NodeList of Nodes
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
  #    $NodeList
  # Example:
  #    my $NodeList = $Document->getElementsByTagNameNS( NamespaceURI => $namespaceURI, LocalName => $localName );
  my $Document     = shift;                                            # Get Document
  my %args         = @_;                                               # Get arguments
  my $NamespaceURI = $args{NamespaceURI};
  my $LocalName    = $args{LocalName};
  my $NodeList     = $NODELIST->new();
  my $TW           = $TREEWALKER->new( Filter => sub { return(1) } );  # Create TreeWalker object
  $TW->walkTree( Node     => $Document,                                # Walk Document tree building NodeList of Nodes
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


=pod
sub importNode(importedNode, deep) {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method returns a Node. The importedNode parameter is of type Node. The deep parameter is of type boolean.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Element = $Document->new( TagName => $tagName );
  my $Document      = shift;                                              # Get Document
  my %args          = @_;                                                 # Get arguments
  return( $Document );                                                    # Return node object
}
=cut


=pod
sub createElementNS(namespaceURI, qualifiedName) {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method returns a Element. The namespaceURI parameter is of type DOMString. The qualifiedName parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Element = $Document->new( TagName => $tagName );
  my $Document      = shift;                                              # Get Document
  my %args          = @_;                                                 # Get arguments
  return( $Document );                                                    # Return node object
}
=cut


=pod
sub createAttributeNS(namespaceURI, qualifiedName) {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method returns a Attr. The namespaceURI parameter is of type DOMString. The qualifiedName parameter is of type DOMString.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    $node
  # Example:
  #    my $Element = $Document->new( TagName => $tagName );
  my $Document      = shift;                                              # Get Document
  my %args          = @_;                                                 # Get arguments
  return( $Document );                                                    # Return node object
}
=cut
