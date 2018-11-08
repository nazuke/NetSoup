#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::Node.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class is the base Node class for the DOM2 package.
#
#
#   Methods:
#       new            -  This method is the object constructor for this class
#       insertBefore   -  This method inserts a new child Node
#       replaceChild   -  This method replaces a child Node
#       removeChild    -  This method removes a child Node
#       appendChild    -  This method appends a new child Node
#       hasChildNodes  -  This method returns a boolean
#       cloneNode      -  This method clones a Node object
#       normalize      -  This method normalises a Node
#       supports       -  This method allows feature support verification


package NetSoup::XML::DOM2::Core::Node;
use strict;
use NetSoup::Core;
use NetSoup::XML::DOM2::Core::NamedNodeMap;
use NetSoup::XML::DOM2::Core::NodeList;
@NetSoup::XML::DOM2::Core::Node::ISA = qw( NetSoup::Core );
my $MODULE       = "Node";
my $NAMEDNODEMAP = "NetSoup::XML::DOM2::Core::NamedNodeMap";
my $NODELIST     = "NetSoup::XML::DOM2::Core::NodeList";
my $NODETYPE     = { 1  => "ELEMENT_NODE",
                     2  => "ATTRIBUTE_NODE",
                     3  => "TEXT_NODE",
                     4  => "CDATA_SECTION_NODE",
                     5  => "ENTITY_REFERENCE_NODE",
                     6  => "ENTITY_NODE",
                     7  => "PROCESSING_INSTRUCTION_NODE",
                     8  => "COMMENT_NODE",
                     9  => "DOCUMENT_NODE",
                     10 => "DOCUMENT_TYPE_NODE",
                     11 => "DOCUMENT_FRAGMENT_NODE",
                     12 => "NOTATION_NODE" };
1;


sub new {
  # This method is the object constructor for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              Debug    => 0 | 1
  #              NodeName => $NodeName
  #              NodeType => $NodeType
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Node = NetSoup::XML::DOM::Parser::Node->new( Name => $name );
  my $package   = shift;                                                                                 # Get package name
  my $class     = ref( $package ) || $package;                                                           # Dereference package into class if necessary
  my %args      = @_;                                                                                    # Get arguments
  my $Node      = {};                                                                                    # Create empty object as hash reference
  my $NodeValue = $args{NodeValue} if( exists $args{NodeValue} );                                        # Account for ZERO integer value
  my $SIG       = "$MODULE\t" . ( $args{NodeName} || $args{NodeType} || "UNKNOWN" );                     # Set up signature
  bless( $Node, $class );                                                                                # Bless object into the $class
  $Node->{Debug}                   = $args{Debug}           || 0;                                        # Set debugging flag
  $Node->{Node}->{NodeName}        = $args{NodeName}        || "";                                       # Type String
  $Node->{Node}->{NodeValue}       = $NodeValue;                                                         # Type String
  $Node->{Node}->{NodeType}        = $args{NodeType}        || $NODETYPE->{1};                           # Type short
  $Node->{Node}->{ParentNode}      = $args{ParentNode}      || undef;                                    # Type Node
  $Node->{Node}->{ChildNodes}      = $args{ChildNodes}      || $NODELIST->new( Debug => $Node->{Debug},  # Type NodeList
                                                                               _Name => $SIG );
  $Node->{Node}->{FirstChild}      = $args{FirstChild}      || undef;                                    # Type Node
  $Node->{Node}->{LastChild}       = $args{LastChild}       || undef;                                    # Type Node
  $Node->{Node}->{PreviousSibling} = $args{PreviousSibling} || undef;                                    # Type Node
  $Node->{Node}->{NextSibling}     = $args{NextSibling}     || undef;                                    # Type Node
  $Node->{Node}->{Attributes}      = $NAMEDNODEMAP->new( Debug => $Node->{Debug},                        # Type NamedNodeMap
                                                         _Name => $SIG );
  $Node->{Node}->{OwnerDocument}   = $args{OwnerDocument}   || undef;                                    # Type Document
  $Node->{Node}->{NamespaceURI}    = $args{NamespaceURI}    || "";                                       # Type String
  $Node->{Node}->{Prefix}          = $args{Prefix}          || "";                                       # Type String
  $Node->{Node}->{LocalName}       = $args{LocalName}       || "";                                       # Type String
  $Node->{Node}->{HasChildNodes}   = 0;                                                                  # Type Boolean
  $Node->{_NetSoup}                = { Indent => $args{Indent} || 0,                                     # NetSoup specific attributes
                                       Line   => $args{Line}   || 0 };
  $Node->initialise( %args );                                                                            # Execute inherited initialise() method
  $Node->_update();                                                                                      # Update internal Node state
  return( $Node );                                                                                       # Return Node object
}


sub initialise {} # Stub for sub-classes


sub _update {
  # This private method updates the internal Node object state.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    bool
  # Example:
  #    $Node->_update();
  my $Node     = shift;                                                # Get Node object
  my %args     = @_;                                                   # Get arguments
  my $NodeList = $Node->childNodes();                                  # Retrieve NodeList object
  my $length   = $NodeList->nodeListLength();                          # Get number of child Nodes
  if( $length == -1 ) {                                                # Re-link Nodes
    $Node->{HasChildNodes}      = 0;                                   # Drop HasChildNodes flag
    $Node->{Node}->{FirstChild} = undef;                               # Link to first ChildNodes member
    $Node->{Node}->{LastChild}  = undef;                               # Link to first ChildNodes member
  } else {
    $Node->{HasChildNodes}      = 1;                                   # Raise HasChildNodes flag
    $Node->{Node}->{FirstChild} = $NodeList->item( Item => 0 );        # Link to first ChildNodes member
    $Node->{Node}->{LastChild}  = $NodeList->item( Item => $length );  # Link to last ChildNodes member
  }
  return(1);
}


sub nodeIndent {
  # This method gets/sets the Node's Indent property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NodeIndent => $NodeIndent
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $NodeIndent = $Node->nodeIndent( NodeIndent => $NodeIndent );
  my $Node = shift;                                   # Get Node object
  my %args = @_;                                      # Get arguments
  if( exists $args{NodeIndent} ) {
    $Node->{_NetSoup}->{Indent} = $args{NodeIndent};  # Set Indent
  }
  return( $Node->{_NetSoup}->{Indent} );
}


sub nodeName {
  # This method gets/sets the Node's NodeName property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NodeName => $NodeName
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $NodeName = $Node->nodeName( NodeName => $NodeName );
  my $Node = shift;                               # Get Node object
  my %args = @_;                                  # Get arguments
  if( exists $args{NodeName} ) {
    $Node->{Node}->{NodeName} = $args{NodeName};  # Set NodeName
  }
  return( $Node->{Node}->{NodeName} );
}


sub nodeValue {
  # This method gets/sets the Node's NodeValue property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NodeValue => $NodeValue
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $NodeValue = $Node->nodeValue( NodeValue => $NodeValue );
  my $Node = shift;                                 # Get Node object
  my %args = @_;                                    # Get arguments
  if( exists $args{NodeValue} ) {
    $Node->{Node}->{NodeValue} = $args{NodeValue};  # Set NodeValue
  }
  return( $Node->{Node}->{NodeValue} );
}


sub nodeType {
  # This method gets/sets the Node's NodeType property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NodeType => $NodeType
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $NodeType = $Node->nodeType( NodeType => $NodeType );
  my $Node = shift;                               # Get Node object
  my %args = @_;                                  # Get arguments
  if( exists $args{NodeType} ) {
    $Node->{Node}->{NodeType} = $args{NodeType};  # Set NodeType
  }
  return( $Node->{Node}->{NodeType} );
}


sub parentNode {
  # This method gets/sets the Node's ParentNode property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              ParentNode => $parentNode
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $parentNode = $Node->parentNode( ParentNode => $parentNode );
  my $Node = shift;                                   # Get Node object
  my %args = @_;                                      # Get arguments
  if( exists $args{ParentNode} ) {
    $Node->{Node}->{ParentNode} = $args{ParentNode};  # Set ParentNode
  }
  return( $Node->{Node}->{ParentNode} );
}


sub childNodes {
  # This method gets/sets the Node's ChildNodes property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              ChildNodes => $childNodes
  #            }
  # Result Returned:
  #    NodeList
  # Example:
  #    my $childNodes = $Node->childNodes( ChildNodes => $childNodes );
  my $Node = shift;                                   # Get Node object
  my %args = @_;                                      # Get arguments
  if( exists $args{ChildNodes} ) {
    $Node->{Node}->{ChildNodes} = $args{ChildNodes};  # Set ChildNodes
  }
  return( $Node->{Node}->{ChildNodes} );
}


sub firstChild {
  # This method gets/sets the Node's FirstChild property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              FirstChild => $firstChild
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $firstChild = $Node->firstChild( FirstChild => $firstChild );
  my $Node = shift;                                   # Get Node object
  my %args = @_;                                      # Get arguments
  if( exists $args{FirstChild} ) {
    $Node->{Node}->{FirstChild} = $args{FirstChild};  # Set FirstChild
  }
  return( $Node->{Node}->{FirstChild} );
}


sub lastChild {
  # This method gets/sets the Node's LastChild property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              LastChild => $lastChild
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $lastChild = $Node->lastChild( LastChild => $lastChild );
  my $Node = shift;                                 # Get Node object
  my %args = @_;                                    # Get arguments
  if( exists $args{LastChild} ) {
    $Node->{Node}->{LastChild} = $args{LastChild};  # Set LastChild
  }
  return( $Node->{Node}->{LastChild} );
}


sub previousSibling {
  # This method gets/sets the Node's PreviousSibling property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              PreviousSibling => $previousSibling
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $previousSibling = $Node->previousSibling( PreviousSibling => $previousSibling );
  my $Node = shift;                                             # Get Node object
  my %args = @_;                                                # Get arguments
  if( exists $args{PreviousSibling} ) {
    $Node->{Node}->{PreviousSibling} = $args{PreviousSibling};  # Set PreviousSibling
  }
  return( $Node->{Node}->{PreviousSibling} );
}


sub nextSibling {
  # This method gets/sets the Node's NextSibling property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NextSibling => $nextSibling
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $nextSibling = $Node->nextSibling( NextSibling => $nextSibling );
  my $Node = shift;                                     # Get Node object
  my %args = @_;                                        # Get arguments
  if( exists $args{NextSibling} ) {
    $Node->{Node}->{NextSibling} = $args{NextSibling};  # Set NextSibling
  }
  return( $Node->{Node}->{NextSibling} );
}


sub attributes {
  # This method gets/sets the Node's Attributes property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Attributes => $attributes
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $attributes = $Node->attributes( NodeName => $attributes );
  my $Node = shift;                                   # Get Node object
  my %args = @_;                                      # Get arguments
  if( exists $args{Attributes} ) {
    $Node->{Node}->{Attributes} = $args{Attributes};  # Set Attributes
  }
  return( $Node->{Node}->{Attributes} );
}


sub ownerDocument {
  # This method gets/sets the Node's OwnerDocument property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              OwnerDocument => $ownerDocument
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $ownerDocument = $Node->ownerDocument( OwnerDocument => $ownerDocument );
  my $Node = shift;                                         # Get Node object
  my %args = @_;                                            # Get arguments
  if( exists $args{OwnerDocument} ) {
    $Node->{Node}->{OwnerDocument} = $args{OwnerDocument};  # Set OwnerDocument
  }
  return( $Node->{Node}->{OwnerDocument} );
}


sub namespaceURI {
  # This method gets/sets the Node's NamespaceURI property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NamespaceURI => $namespaceURI
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $namespaceURI = $Node->namespaceURI( NamespaceURI => $namespaceURI );
  my $Node = shift;                                       # Get Node object
  my %args = @_;                                          # Get arguments
  if( exists $args{NamespaceURI} ) {
    $Node->{Node}->{NamespaceURI} = $args{NamespaceURI};  # Set NamespaceURI
  }
  return( $Node->{Node}->{NamespaceURI} );
}


sub prefix {
  # This method gets/sets the Node's Prefix property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Prefix => $prefix
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $prefix = $Node->prefix( Prefix => $prefix );
  my $Node = shift;                           # Get Node object
  my %args = @_;                              # Get arguments
  if( exists $args{Prefix} ) {
    $Node->{Node}->{Prefix} = $args{Prefix};  # Set Prefix
  }
  return( $Node->{Node}->{Prefix} );
}


sub localName {
  # This method gets/sets the Node's LocalName property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              LocalName => $localName
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $localName = $Node->localName( LocalName => $localName );
  my $Node = shift;                                 # Get Node object
  my %args = @_;                                    # Get arguments
  if( exists $args{LocalName} ) {
    $Node->{Node}->{LocalName} = $args{LocalName};  # Set LocalName
  }
  return( $Node->{Node}->{LocalName} );
}


sub insertBefore {
  # This method inserts a new child Node before the referenced child Node in the child Nodes list.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NewChild => $newChild
  #              RefChild => $refChild
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $Node->insertBefore( NewChild => $newChild, RefChild => $refChild );
  my $Node = shift;                                                           # Get Node object
  my %args = @_;                                                              # Get arguments
  $args{NewChild}->ownerDocument( OwnerDocument => $Node->ownerDocument() );  # Link NewChild to Parent Node
  $args{NewChild}->parentNode( ParentNode => $Node );                         # Link NewChild to Parent Node
  $Node->childNodes()->_insertBefore( NewNode => $args{NewChild},             # Update NodeList
                                      RefNode => $args{RefChild} );
  $Node->_update();                                                           # Update internal Node state
  return( $Node );
}


sub replaceChild {
  # This method replaces a child Node in the child Node list.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NewChild => $newChild
  #              OldChild => $oldChild
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $Node->replaceChild( NewChild => $newChild, OldChild => $oldChild );
  my $Node = shift;                                                           # Get Node object
  my %args = @_;                                                              # Get arguments
  $Node->insertBefore( NewChild => $args{NewChild},
                       RefChild => $args{OldChild} );
  $Node->removeChild( OldChild => $args{OldChild} );
  $args{NewChild}->ownerDocument( OwnerDocument => $Node->ownerDocument() );  # Link NewChild to Parent Node
  $args{NewChild}->parentNode( ParentNode => $Node );                         # Link NewChild to Parent Node
  return( $Node );
}


sub removeChild {
  # This method removes a child Node from the child Node list.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              OldChild => $oldChild
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $Node->removeChild( OldChild => $oldChild );
  my $Node = shift;                                                  # Get Node object
  my %args = @_;                                                     # Get arguments
  $Node->childNodes()->_removeChild( OldChild => $args{OldChild} );  # Update NodeList
  $Node->_update();                                                  # Update internal Node state
  return( $Node );
}


sub appendChild {
  # This method appends a new child Node to the child Node list.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NewChild => $newChild
  #            }
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $Node->appendChild( NewChild => $newChild );
  my $Node = shift;                                                           # Get Node object
  my %args = @_;                                                              # Get arguments
  $Node->childNodes()->appendNode( Node => $args{NewChild} );                           # Append Node to child NodeList
  $args{NewChild}->ownerDocument( OwnerDocument => $Node->ownerDocument() );  # Link NewChild to Parent Node
  $args{NewChild}->parentNode( ParentNode => $Node );                         # Link NewChild to Parent Node
  $Node->{HasChildNodes} = 1;                                                 # Raise HasChildNodes flag
  $Node->_update();                                                           # Update internal Node state
  return( $Node );
}


sub hasChildNodes {
  # This method returns a boolean indicating the presence of child Nodes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    my $bool = $Node->hasChildNodes();
  my $Node = shift;                  # Get Node object
  my %args = @_;                     # Get arguments
  $Node->_update();                  # Update internal Node state
  return( $Node->{HasChildNodes} );  # Return flag state
}


sub cloneNode {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method clones a Node object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $clone = $Node->cloneNode();
  my $Node = shift;  # Get Node object
  my %args = @_;     # Get arguments

  return( $Node );
}


sub normalize {
  # This method normalises a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    $Node->normalize();
  my $Node = shift;  # Get Node object
  my %args = @_;     # Get arguments
  $Node->_update();  # Update internal Node state
  return( $Node );
}


sub supports {
##############################
# THIS METHOD UNIMPLEMENTED! #
##############################
  # This method allows feature support verification.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Feature => $feature
  #              Version => $version
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $bool = $Node->supports( Feature => $feature, Version => $version );
  my $Node    = shift;           # Get Node object
  my %args    = @_;              # Get arguments
  my $feature = $args{Feature};  #
  my $version = $args{Version};  #

  return(0);
}


sub nsNodeDepth {
  # This method gets the Node's nested depth value.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    int
  # Example:
  #    my $depth = $Node->nodeDepth();
  my $Node = shift;               # Get Node object
  my %args = @_;                  # Get arguments
  return( $Node->nodeIndent() );  # Thunk down to nodeIndent()
}


sub DESTROY {
  # This method is the object destructor for this class.
  my $Node = shift;
  if( defined $Node->{Node}->{ChildNodes} ) {
    my $NodeList = $Node->{Node}->{ChildNodes};
    for( my $i = 0 ; $i <= $NodeList->nodeListLength() ; $i++ ) {
      my $item = $NodeList->item( Item => $i );
      if( defined $item ) {
        $item->DESTROY();
        $item->ownerDocument( OwnerDocument => {} );
        $item->parentNode( ParentNode => {} );
      }
    }
  }
  if( defined $Node->{Node}->{Attributes} ) {
    $Node->{Node}->{Attributes}->DESTROY();
  }
  undef %{$Node->{Node}};
  undef %{$Node};
  return(1);
}
