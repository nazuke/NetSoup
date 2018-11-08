#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser::Compiler.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class is part of the XML DOM2 system.
#                This particular class compiles the preprocessed symbol
#                table into a parse tree.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       compile     -  This method compiles the Symbol table into a Document object
#       _compile    -  This private method compiles the Symbol table into a NodeList object


package NetSoup::XML::Parser::Compiler;
use strict;
use NetSoup::Core;
use NetSoup::XML::Parser::Errors;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::DOM2::Core::DocumentType;
use NetSoup::XML::DOM2::Core::NodeList;
use NetSoup::XML::DOM2::Core::CDATASection;
use NetSoup::XML::DOM2::Core::CharacterData;
use NetSoup::XML::DOM2::Core::Comment;
use NetSoup::XML::DOM2::Core::Element;
use NetSoup::XML::DOM2::Core::Text;
@NetSoup::XML::Parser::Compiler::ISA = qw( NetSoup::Core
                                           NetSoup::XML::Parser::Errors );
my $MODULE        = "Compiler";
my $DOCUMENT      = "NetSoup::XML::DOM2::Core::Document";
my $CDATASECTION  = "NetSoup::XML::DOM2::Core::CDATASection";
my $CHARACTERDATA = "NetSoup::XML::DOM2::Core::CharacterData";
my $COMMENT       = "NetSoup::XML::DOM2::Core::Comment";
my $DOCTYPE       = "NetSoup::XML::DOM2::Core::DocumentType";
my $ELEMENT       = "NetSoup::XML::DOM2::Core::Element";
my $NODELIST      = "NetSoup::XML::DOM2::Core::NodeList";
my $TEXT          = "NetSoup::XML::DOM2::Core::Text";
my %ERRORS        = ();
while( <NetSoup::XML::Parser::Compiler::DATA> ) {
  chomp;
  last if( ! length );
  my( $key, $value ) = split( /\t+/ );
  $ERRORS{$key}      = $value;
}
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    Compiler
  #    hash    {
  #              Debug   => 0 | 1
  #              Symbols => \@Symbols
  #            }
  # Result Returned:
  #    Compiler
  # Example:
  #    $Compiler->initialise();
  my $Compiler         = shift;              # Get Preprocessor object
  my %args             = @_;                 # Get arguments
  $Compiler->{Debug}   = $args{Debug} || 0;  # Get debugging flag
  $Compiler->{Symbols} = $args{Symbols};     # Get Symbol table
  $Compiler->{Errors}  = {};
  return( $Compiler );
}


sub compile {
  # This method compiles the Symbol table into a Document object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Whitespace => "preserve" | "compact"
  #            }
  # Result Returned:
  #    Document
  # Example:
  #    my $Document = $Compiler->compile();
  my $Compiler = shift;                                                     # Get object
  my %args     = @_;                                                        # Get arguments
  my $Document = $DOCUMENT->new( Debug => $Compiler->{Debug} );             # Create new Document object
  $Compiler->clearErr();                                                    # Clear error messages
  my $NodeList = $Compiler->_compile( Symbols    => $Compiler->{Symbols},   # Begin recursive compilation
                                      Parent     => $Document,
                                      Whitespace => $args{Whitespace},
                                      Indent     => 0 );
  if( defined $NodeList ) {                                                 # Check for successful compilation
    print( STDERR "\t\tCompiled NodeList\n" ) if( $Compiler->{Debug} );
  APPEND: for( my $i = 0 ; $i <= $NodeList->nodeListLength() ; $i++ ) {
      my $NewChild = $NodeList->item( Item => $i ) || last APPEND;          # Get Node object
      $Document->appendChild( NewChild => $NewChild );
    }
  } else {
    print( STDERR "\t\tFailed NodeList Compilation\n" ) if( $Compiler->{Debug} );  # DEBUG
    return( undef );
  }
  return( $Document );
}


sub _compile {
  # This private method compiles the Symbol table into a NodeList object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Symbols    => \@Symbols
  #              Whitespace => "preserve" | "compact"
  #            }
  # Result Returned:
  #    $NodeList
  # Example:
  #    my $DOM = $Compiler->_compile( Symbols => \@Symbols );
  my $Compiler   = shift;                                                                              # Get object
  my %args       = @_;                                                                                 # Get arguments
  my @Symbols    = @{$args{Symbols}};                                                                  # Make local copy of symbols array
  my $whitespace = $args{Whitespace} || "compact";                                                     # Get white space flag
  my $indent     = $args{Indent}     || 0;                                                             # Get current indent level
  my $NodeList   = $NODELIST->new( Debug => $Compiler->{Debug},                                        # Create new NodeList object
                                   _Name => $MODULE );
  my $ParentNode = $args{ParentNode} || undef;                                                         # Tracks the parent node
 LOAD: for( my $i = 0 ; $i <= @Symbols - 1 ; $i++ ) {                                                  # Iterate over parsed symbols
  ELEMENT: for my $nodeType ( $Symbols[$i]->nodeType() ) {                                             # Is this a tag?
      last ELEMENT if( $Symbols[$i]->nodeClosing() );                                                  # Ignore closing tags
      # XML Element Node
      $nodeType =~ m/ELEMENT_NODE/ && do {
        print( STDERR "\t\tCompiling " . $Symbols[$i]->nodeValue() . "\n" ) if( $Compiler->{Debug} );
        for( $Symbols[$i]->nodeEmpty() ) {                                                             # Process empty XML tags
          # Empty XML Element
          m/1/ && do {
            my $length          = $NodeList->nodeListLength();
            my $PreviousSibling = $NodeList->item( Item => $length - 1 );
            my $Node            = $ELEMENT->new( Debug           => $Compiler->{Debug},
                                                 NodeName        => $Symbols[$i]->nodeName(),
                                                 NodeValue       => $Symbols[$i]->nodeValue(),
                                                 NodeType        => $Symbols[$i]->nodeType(),
                                                 ParentNode      => $ParentNode,
                                                 PreviousSibling => $PreviousSibling,
                                                 NamespaceURI    => $Symbols[$i]->nodeNamespace(),
                                                 Indent          => $indent,
                                                 Line            => $Symbols[$i]->lineNumber() );
            my $Attributes = $Symbols[$i]->nodeAttributes();
            foreach my $atname ( keys %{$Attributes} ) {
              $Node->setAttribute( Name  => $atname,
                                   Value => $Attributes->{$atname} );                                  # Add new attribute node
            }
            $PreviousSibling->nextSibling( NextSibling => $Node ) if( defined $PreviousSibling );      # Set PreviousSibling's NextSibling property to this node
            $NodeList->appendNode( Node => $Node );                                                    # Append Node to NodeList
            last ELEMENT;
          };


          # Populated XML Element
          m/0/ && do {
            my $namespace       = $Symbols[$i]->nodeNamespace();
            my $tagname         = $Symbols[$i]->nodeName();
            my $length          = $NodeList->nodeListLength();
            my $PreviousSibling = $NodeList->item( Item => $length - 1 );
            my $Node            = $ELEMENT->new( Debug           => $Compiler->{Debug},
                                                 NodeName        => $tagname,
                                                 NodeValue       => $Symbols[$i]->nodeValue(),
                                                 NodeType        => $Symbols[$i]->nodeType(),
                                                 ParentNode      => $ParentNode,
                                                 PreviousSibling => $PreviousSibling,
                                                 NamespaceURI    => $namespace,
                                                 Indent          => $indent,
                                                 Line            => $Symbols[$i]->lineNumber() );
            my $Attributes = $Symbols[$i]->nodeAttributes();
            foreach my $atname ( keys %{$Attributes} ) {
              $Node->setAttribute( Name  => $atname,
                                   Value => $Attributes->{$atname} );                                  # Add new attribute node
            }
            $PreviousSibling->nextSibling( NextSibling => $Node ) if( defined $PreviousSibling );      # Set PreviousSibling's NextSibling property to this node
            my @children  = ();                                                                        # Array for child DOM nodes
            my $noClosing = 1;                                                                         # Flag for missing closing tag
            my $sample    = $Symbols[$i]->nodeValue();                                                 # Store tag as error sample
            my %state     = ( Nested => {} );                                                          # Compiler state flags hash
          SUBNODE: for( $i = $i + 1 ; $i <= @Symbols - 1 ; $i++ ) {                                    # Iterate over parsed symbols
              my $subnamespace           = $Symbols[$i]->nodeNamespace();
              my $subname                = $Symbols[$i]->nodeName();
              $state{Nested}->{$tagname} = 0 if( ! $state{Nested}->{$tagname} );                       # Initialise nesting flags for this XML tag
              push( @children, $Symbols[$i] );                                                         # Add entity to sub-symbols
              if( ( $namespace eq $subnamespace ) && ( $tagname eq $subname ) ) {                      # Looking for closing XML tag
                next SUBNODE if( $Symbols[$i]->nodeEmpty() );
                if( $Symbols[$i]->nodeClosing() == 0 ) {                                               # Don't sub-node closing XML tags with same name
                  $state{Nested}->{$tagname}++;                                                        # Increment nested XML tag counter
                  next SUBNODE;
                } elsif( $state{Nested}->{$tagname} > 0 ) {                                            # Don't sub-node nested XML tags with same name
                  $state{Nested}->{$tagname}--;                                                        # Decrement nested XML tag counter
                  next SUBNODE;
                } else {
                  ;                                                                                    # Fall through...
                }
                my $childNodeList = $Compiler->_compile( ParentNode => $Node,                           # Sub-process child nodes
                                                         Symbols    => \@children,
                                                         Whitespace => $whitespace,
                                                         Indent     => $indent + 1,
                                                         Line       => $Symbols[$i]->lineNumber() );
                if( defined $childNodeList ) {                                                         # Undefined indicates an unterminated element
                APPEND: for( my $i = 0 ; $i <= $childNodeList->nodeListLength() ; $i++ ) {
                    my $NewChild = $childNodeList->item( Item => $i ) || last APPEND;                  # Get Node object
                    $Node->appendChild( NewChild => $NewChild );
                  }
                  $noClosing = 0;                                                                      # Lower missing closing tag flag
                  last SUBNODE;                                                                        # Break sub-processing
                }
              }
            }
            if( $noClosing ) {                                                                         # Check for missing closing XML tag
              $Compiler->_error( Errors => \%ERRORS,                                                   # Generate error message
                                 Module => $MODULE,
                                 Line   => $i,
                                 Code   => "0001",
                                 String => $tagname,
                                 Sample => $sample );
              $NodeList->DESTROY();                                                                    # Explicitly destroy NodeList object
              return( undef );                                                                         # Return on error
            }
            $NodeList->appendNode( Node => $Node );                                                    # Append Node to NodeList
            last ELEMENT;
          };
        }
        last ELEMENT;
      };
      # Text Node
      $nodeType =~ m/TEXT_NODE/ && do {
        if( $Compiler->{Debug} ) {
          print( STDERR "\t\tCompiling " . $Symbols[$i]->nodeType()  . "\n" );
          print( STDERR "\t\t          " . $Symbols[$i]->nodeValue() . "\n" );
        }
        if( ! defined $ParentNode ) {
          my ( $sample ) = ( $Symbols[$i]->nodeValue() =~ m/^(.{1,20})/ );
          $Compiler->_error( Errors  => \%ERRORS,                                                       # Generate error message
                             Module  => $MODULE,
                             Line    => $Symbols[$i]->lineNumber(),
                             Code    => "0002",
                             String  => $sample,
                             Context => $Symbols[$i]->nodeType(),
                             Sample  => $Symbols[$i]->nodeValue() );
          $NodeList->DESTROY();    # Explicitly destroy NodeList object
          return( undef );                                                                             # Return on error
        }
        if( $whitespace =~ m/compact/i ) {
          my ( $value ) = ( $Symbols[$i]->nodeValue() =~ m/^[ \t]*([ \t]?.+[ \t]?)[ \t]*$/gs );        # Compact white space
          $Symbols[$i]->nodeValue( NodeValue => $value );
        }
        my $length          = $NodeList->nodeListLength();
        my $PreviousSibling = $NodeList->item( Item => $length - 1 );
        my $Node            = $TEXT->new( Debug           => $Compiler->{Debug},
                                          NodeName        => $nodeType,
                                          NodeValue       => $Symbols[$i]->nodeValue(),
                                          NodeType        => $Symbols[$i]->nodeType(),
                                          ParentNode      => $ParentNode,
                                          PreviousSibling => $PreviousSibling,
                                          Indent          => $indent,
                                          Line            => $Symbols[$i]->lineNumber() );
        $PreviousSibling->nextSibling( NextSibling => $Node ) if( defined $PreviousSibling );          # Set PreviousSibling's NextSibling property to this node
        $NodeList->appendNode( Node => $Node );                                                        # Append Node to NodeList
        last ELEMENT;
      };
      # CDATA Section Node
      $nodeType =~ m/CDATA_SECTION_NODE/ && do {
        print( STDERR "\t\tCompiling " . $Symbols[$i]->nodeType() . "\n" ) if( $Compiler->{Debug} );
        my $length          = $NodeList->nodeListLength();
        my $PreviousSibling = $NodeList->item( Item => $length - 1 );
        my $Node            = $CDATASECTION->new( Debug           => $Compiler->{Debug},
                                                  NodeName        => $nodeType,
                                                  NodeValue       => $Symbols[$i]->nodeValue(),
                                                  NodeType        => $Symbols[$i]->nodeType(),
                                                  ParentNode      => $ParentNode,
                                                  PreviousSibling => $PreviousSibling,
                                                  Indent          => $indent,
                                                  Line            => $Symbols[$i]->lineNumber() );
        $PreviousSibling->nextSibling( NextSibling => $Node ) if( defined $PreviousSibling );          # Set PreviousSibling's NextSibling property to this node
        $NodeList->appendNode( Node => $Node );                                                        # Append Node to NodeList
        last ELEMENT;
      };
      # Processing Instruction Node
      $nodeType =~ m/PROCESSING_INSTRUCTION_NODE/ && do {
        last ELEMENT; # DEBUG
        print( STDERR "\t\tCompiling " . $Symbols[$i]->nodeType() . "\n" ) if( $Compiler->{Debug} );
        my $namespace       = $Symbols[$i]->nodeNamespace();
        my $tagname         = $Symbols[$i]->nodeName();
        my $length          = $NodeList->nodeListLength();
        my $PreviousSibling = $NodeList->item( Item => $length - 1 );
        my $Node            = $ELEMENT->new( Debug           => $Compiler->{Debug},
                                             NodeName        => $tagname,
                                             NodeValue       => $Symbols[$i]->nodeValue(),
                                             NodeType        => $Symbols[$i]->nodeType(),
                                             ParentNode      => $ParentNode,
                                             PreviousSibling => $PreviousSibling,
                                             NamespaceURI    => $namespace,
                                             Indent          => $indent,
                                             Line            => $Symbols[$i]->lineNumber() );
        $PreviousSibling->nextSibling( NextSibling => $Node ) if( defined $PreviousSibling );          # Set PreviousSibling's NextSibling property to this node
        $NodeList->appendNode( Node => $Node );                                                        # Append Node to NodeList
        last ELEMENT;
      };
      # Comment Node
      $nodeType =~ m/COMMENT_NODE/ && do {
        print( STDERR "\t\tCompiling " . $Symbols[$i]->nodeType() . "\n" ) if( $Compiler->{Debug} );
        my $length          = $NodeList->nodeListLength();
        my $PreviousSibling = $NodeList->item( Item => $length - 1 );
        my $Node            = $COMMENT->new( Debug           => $Compiler->{Debug},
                                             NodeName        => $Symbols[$i]->nodeType(),
                                             NodeValue       => $Symbols[$i]->nodeValue(),
                                             NodeType        => $Symbols[$i]->nodeType(),
                                             ParentNode      => $ParentNode,
                                             PreviousSibling => $PreviousSibling,
                                             Indent          => $indent,
                                             Line            => $Symbols[$i]->lineNumber() );
        $PreviousSibling->nextSibling( NextSibling => $Node ) if( defined $PreviousSibling );          # Set PreviousSibling's NextSibling property to this node
        $NodeList->appendNode( Node => $Node );                                                        # Append Node to NodeList
        last ELEMENT;
      };
      # Document Type Node
      $nodeType =~ m/DOCUMENT_TYPE_NODE/ && do {
        print( STDERR "\t\tCompiling " . $Symbols[$i]->nodeType() . "\n" ) if( $Compiler->{Debug} );
        my $length          = $NodeList->nodeListLength();
        my $PreviousSibling = $NodeList->item( Item => $length - 1 );
        my $doctype         = $Symbols[$i]->nodeDoctype();
        my $Node            = $DOCTYPE->new( Debug     => $Compiler->{Debug},
                                             NodeType  => $Symbols[$i]->nodeType(),
                                             Name      => $doctype->{Name},
                                             Root      => $doctype->{Root},
                                             Entities  => undef,
                                             Notations => undef,
                                             PublicID  => $doctype->{ID},
                                             SystemID  => $doctype->{ID},
                                             URI       => $doctype->{URI},
                                             Indent    => $indent,
                                             Line      => $Symbols[$i]->lineNumber() );
        $PreviousSibling->nextSibling( NextSibling => $Node ) if( defined $PreviousSibling );          # Set PreviousSibling's NextSibling property to this node
        $NodeList->appendNode( Node => $Node );                                                        # Append Node to NodeList
        last ELEMENT;
      };
    }
  }
  return( $NodeList );
}


sub DESTROY {
  my $Compiler         = shift;
  $Compiler->{Symbols} = undef;
  return(1);
}


__DATA__
0001  Unterminated element __
0002  !! __ outside of containing element
