#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Traversal::Serialise.pm v00.00.01z 12042000
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
#   Description: This Perl 5.0 is part of the XML package, providing methods
#                for serialising a DOM2 object to an XML data stream.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class


package NetSoup::XML::DOM2::Traversal::Serialise;
use strict;
use NetSoup::Core;
use constant TAB => " " x 4;
use constant NL  => "\x0A";
@NetSoup::XML::DOM2::Traversal::Serialise::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              WhatToShow             => $whatToShow
  #              Filter                 => sub {}
  #              ExpandEntityReferences => 0 | 1
  #              CurrentNode            => $node
  #              StrictSGML             => 0 | 1
  #              HTMLMode               => 0 | 1
  #              OmitPI                 => 0 | 1
  #              Compact                => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Serialise = NetSoup::XML::DOM2::Traversal::Serialise->new();
  my $Serialise                        = shift;                                               # Get Serialise object
  my %args                             = @_;                                                  # Get arguments
  $Serialise->{WhatToShow}             = $args{WhatToShow}             || 0;                  # Type long
  $Serialise->{Filter}                 = $args{Filter}                 || sub { return(1) };  # Type NodeFilter
  $Serialise->{ExpandEntityReferences} = $args{ExpandEntityReferences} || 0;                  # Type boolean
  $Serialise->{CurrentNode}            = $args{CurrentNode};                                  # Type Node
  $Serialise->{StrictSGML}             = $args{StrictSGML}             || 0;                  # Strict SGML formatting
  $Serialise->{OmitPI}                 = $args{OmitPI}                 || 0;                  # Omit Processing Instructions from output
  $Serialise->{Compact}                = $args{Compact}                || 0;                  # No NLs
  return( $Serialise );                                                                       # Return blessed Serialise object
}


sub serialise {
  # This method walks a sub-tree from top to bottom,
  # serialising the contents to the Target scalar.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node          => $node
  #              Target        => \$target
  #              CallbackOpen  => sub {}
  #              CallbackClose => sub {}
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Serialise->serialise( Node => $node, Target => \$target );
  my $Serialise = shift;                                            # Get Serialise object
  my %args      = @_;                                               # Get arguments
  my $target    = $args{Target};                                    # Get opening callback to execute
  $$target      = "";
  $Serialise->_serialise( Node          => $args{Node},
                          Target        => $args{Target},
                          CallbackOpen  => $args{CallbackOpen},
                          CallbackClose => $args{CallbackClose} );
  return(1);
}


sub _serialise {
  # This method walks a sub-tree from top to bottom,
  # serialising the contents to the Target scalar.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node          => $node
  #              Target        => \$target
  #              CallbackOpen  => sub {}
  #              CallbackClose => sub {}
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Serialise->_serialise( Node => $node, Target => \$target );
  my $Serialise = shift;                                            # Get Serialise object
  my %args      = @_;                                               # Get arguments
  my $Node      = $args{Node}     || $Serialise->{CurrentNode};     # Get Node object
  my $target    = $args{Target};                                    # Get target scalar reference
  my $callback_o  = $args{CallbackOpen} || undef;                   # Get opening callback to execute
  my $callback_c  = $args{CallbackClose} || undef;                  # Get opening callback to execute
  $$target     .= $Serialise->_opening( Node => $Node );            # Serialise opening tag
  if( $Node->hasChildNodes() ) {
    my $NodeList = $Node->childNodes();
    my $length   = $NodeList->nodeListLength();
  CHILD: for( my $i = 0 ; $i <= $length ; $i++ ) {
      my $ChildNode = $NodeList->item( Item => $i ) || last CHILD;  # Get child node
      if( defined $callback_o ) {
      SWITCH: for( &$callback_o( $Node ) ) {
          m/^1$/ && do {
            $Serialise->_serialise( Node          => $ChildNode,
                                    Target        => $target,
                                    CallbackOpen  => $callback_o,
                                    CallbackClose => $callback_c  );
            last SWITCH;
          };
          m/^0$/ && do {
            last SWITCH;
          };
        }
      } else {
        $Serialise->_serialise( Node => $ChildNode, Target => $target );
      }
    }
  }
  $$target .= $Serialise->_closing( Node => $Node );                # Serialise closing tag
  return(1);
}


sub _opening {
  # This private method serialises the opening tag.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node => $node
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $target .= $Serialise->_opening( Node => $node );
  my $Serialise = shift;                                 # Get Serialise object
  my %args      = @_;                                    # Get arguments
  my $Node      = $args{Node} || return(1);              # Get Node object
  my $target    = "";
 SWITCH: for( $Node->nodeType() ) {
    m/PROCESSING_INSTRUCTION_NODE/ && do {
      last SWITCH if( $Serialise->{OmitPI} );
      last SWITCH if( $Serialise->{StrictSGML} );
      $target .= TAB x $Node->nodeIndent() . '<?' . $Node->target() . ' '  . $Node->data() . '?>' if( ! $Serialise->{Compact} );
      $target .= NL if( ! $Serialise->{Compact} );
      last SWITCH;
    };
    m/ELEMENT_NODE/ && do {
      $target  = TAB x $Node->nodeIndent() if( ! $Serialise->{Compact} );
      $target .= '<';
      $target .= ( $Node->namespaceURI() . ':' ) if( $Node->namespaceURI() );
      $target .= $Node->nodeName();
      $target .= $Serialise->_attribs( Node => $Node );
      if( ! $Node->hasChildNodes() ) {
        if( $Serialise->{StrictSGML} ) {
          $target .= '>';
          last SWITCH;
        } else {
          $target .= ' />';
        }
      } else {
        $target .= '>';
      }
      if( ( $Node->hasChildNodes() ) &&
          ( $Node->childNodes()->nodeListLength() == 1 ) &&
          ( $Node->firstChild()->nodeType() eq 'TEXT_NODE' ) ) {
        last SWITCH;
      }
      $target .= NL if( ! $Serialise->{Compact} );
      last SWITCH;
    };
    m/TEXT_NODE/ && do {
      if( $Node->parentNode()->childNodes()->nodeListLength() == 1 ) {
        $target .= $Node->nodeValue();
      } else {
        $target .= TAB x $Node->nodeIndent() . $Node->nodeValue();
        $target .= NL if( ! $Serialise->{Compact} );
      }
      last SWITCH;
    };
    m/CDATA_SECTION_NODE/ && do {
      $target .= TAB x $Node->nodeIndent() . '<![CDATA[' . $Node->nodeValue() . ']]>';
      $target .= NL if( ! $Serialise->{Compact} );
      last SWITCH;
    };
    m/COMMENT_NODE/ && do {
      $target .= TAB x $Node->nodeIndent() . '<!--' . $Node->data() . '-->';
      $target .= NL if( ! $Serialise->{Compact} );
      last SWITCH;
    };
  }
  return( $target );
}


sub _attribs {
  # This private method serialises the tag attributes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node => $node
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $target .= $Serialise->_closing( Node => $node );
  my $Serialise = shift;                                       # Get Serialise object
  my %args      = @_;                                          # Get arguments
  my $Node      = $args{Node} || return(1);                    # Get Node object
  my $target    = "";
 SWITCH: for( $Node->nodeType() ) {
    m/ELEMENT_NODE/ && do {
      my $NamedNodeMap = $Node->attributes() || last SWITCH;   # Get attributes node
      my $length       = $NamedNodeMap->namedNodeMapLength();  # Get number of attributes
      last SWITCH if( $length == -1 );                         # Skip if no attributes
    ATTRIBS: for( my $i = 0 ; $i <= $length ; $i++ ) {
        my $attrib = $NamedNodeMap->item( Index => $i );
        last ATTRIBS if( ! defined $attrib );
        my $value = $attrib->nodeValue();
        $value    =~ s/\"/&quot;/gs;
        $target  .= " ";
        $target  .= $attrib->nodeName();
        $target  .= qq(="$value");
      }
      last SWITCH;
    };
  }
  return( $target );
}


sub _closing {
  # This private method serialises the closing tag.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node => $node
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $target .= $Serialise->_closing( Node => $node );
  my $Serialise = shift;                              # Get Serialise object
  my %args      = @_;                                 # Get arguments
  my $Node      = $args{Node} || return(1);           # Get Node object
  my $target    = "";
 SWITCH: for( $Node->nodeType() ) {
    m/ELEMENT_NODE/ && do {
      if( ( ! $Node->hasChildNodes() ) && ( $Serialise->{StrictSGML} ) ) {
        $target .= '</';
        $target .= ( $Node->namespaceURI() . ':' ) if( $Node->namespaceURI() );
        $target .= $Node->nodeName()  . '>';
        $target .= NL if( ! $Serialise->{Compact} );
        last SWITCH;
      }
=pod
      if( ( $Node->childNodes()->nodeListLength() == 1 ) &&
          ( $Node->firstChild()->nodeType() eq 'TEXT_NODE' ) ) {
        $target .= '</';
        $target .= ( $Node->namespaceURI() . ':' ) if( $Node->namespaceURI() );
        $target .= $Node->nodeName() . '>';
        $target .= NL if( ! $Serialise->{Compact} );
        last SWITCH;
      }
=cut
      if( $Node->hasChildNodes() ) {
        $target = "";
        if( ! $Serialise->{Compact} ) {
          $target .= TAB x $Node->nodeIndent() if( $Node->firstChild()->nodeType() ne 'TEXT_NODE' );
        }
        $target .= '</';
        $target .= ( $Node->namespaceURI() . ':' ) if( $Node->namespaceURI() );
        $target .= $Node->nodeName() . '>';
        $target .= NL if( ! $Serialise->{Compact} );
        last SWITCH;
      }
    };
  }
  return( $target );
}
