#!/usr/local/bin/perl
#
#   NetSoup::XML::Validator.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class is part of the DOM2 XML system.
#                This class provides a validating wrapper over the
#                XML Parser class.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       validate    -  This method parses a chunk of XML text into a DOM2 parse tree and validates it against the DTD


package NetSoup::XML::Validator;
use strict;
use NetSoup::Files::Load;
use NetSoup::XML::Parser;
use NetSoup::XML::Parser::DTD;
use NetSoup::XML::Parser::Errors;
use NetSoup::XML::Parser::Preprocessor;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
@NetSoup::XML::Validator::ISA = qw( NetSoup::XML::Parser
                                    NetSoup::XML::Parser::Errors );
my $MODULE       = "Validator";
my %ERRORS       = ();
my $PARSER       = "NetSoup::XML::Parser";
my $PREPROCESSOR = "NetSoup::XML::Parser::Preprocessor";
my $COMPILER     = "NetSoup::XML::Parser::DTD";
my $DT           = "NetSoup::XML::DOM2::Traversal::DocumentTraversal";
my %NODETYPE     = ( 1  => "ELEMENT_NODE",
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
                     12 => "NOTATION_NODE" );
while( <NetSoup::XML::Validator::DATA> ) {
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
  #    Validator
  #    hash    {
  #              Debug => 0 | 1
  #              XML   => \$xml
  #            }
  # Result Returned:
  #    Validator
  # Example:
  #    $Validator->initialise();
  my $Validator          = shift;          # Get Validator object
  my %args               = @_;             # Get arguments
  $Validator->SUPER::initialise( %args );  # Perform base class initialisation
  $Validator->{DTD}      = undef;          # Initialise DTD object container
  $Validator->{Compiled} = undef;          # Compiled DTD
  return( $Validator );
}


sub validate {
  # This method parses a chunk of XML text and validates it against the DTD.
  # Calls:
  #    none
  # Parameters Required:
  #    Validator
  #    hash    {
  #              Whitespace => "preserve" || "compact"
  #            }
  # Result Returned:
  #    $Validator || undef
  # Example:
  #    method call
  my $Validator  = shift;                                                                     # Get Validator
  my %args       = @_;                                                                        # Get arguments
  my $XML        = $args{XML}        || undef;                                                # Get reference to XML text
  my $whitespace = $args{Whitespace} || "compact";                                            # Get white space flag
  $Validator->clearErr();                                                                     # Clear accumulated error messages
  my $Document = $Validator->parse( XML        => $XML,
                                    Whitespace => $whitespace );                              # Parse XML document
  if( defined $Document ) {                                                                   # Check for parsing failure
    my $DOCTYPE    = undef;                                                                   # Will hold DOCTYPE Node
    my $Traverser  = $DT->new();
    my $TreeWalker = $Traverser->createTreeWalker( Root                     => $Document,
                                                   WhatToShow               => undef,
                                                   Filter                   => sub {
                                                     my $Node = shift;
                                                     if( $Node->nodeName() =~ m/DOCTYPE/ ) {  # Operate only on DOCTYPE Nodes
                                                       return(1);
                                                     }
                                                   },
                                                   EntityReferenceExpansion => 0 );
    $TreeWalker->walkTree( Node     => $Document,                                             # Walk the Document tree
                           Callback => sub {
                             my $Node = shift;
                             $DOCTYPE = $Node;
                             return(1);
                           } );
    if( ! defined $DOCTYPE ) {                                                                # Return on missing DOCTYPE element
      $Validator->{Flags}->{Error} = 1;                                                       # Raise error flag
      return( undef );
    }
  ID: for( $DOCTYPE->publicID() . $DOCTYPE->systemID() ) {                                    # Load DTD Text
      m/PUBLIC/ && do {                                                                       # Load DTD from network
        $Validator->getPublic( URI => $DOCTYPE->URI() );
        last ID;
      };
      m/SYSTEM/ && do {                                                                       # Load DTD from local file
        $Validator->getSystem( URI => $DOCTYPE->URI() );
        last ID;
      };
      m// && do {
        $Validator->{Flags}->{Error} = 1;                                                     # Raise error flag
        return( undef );
      };
    }
    my $Compiled = $Validator->_compile();                                                    # Compile the DTD
    if( defined $Compiled ) {
      if( ! defined $Validator->_execute( Document => $Document ) ) {                                   # Execute Validation Suite
        $Validator->{Flags}->{Error} = 1;                                                     # Raise error flag
        return( undef );                                                                      # Return on error
      }
    } else {
      $Validator->{Flags}->{Error} = 1;                                                       # Raise error flag
      return( undef );                                                                        # Return on error
    }
  } else {
    $Validator->{Flags}->{Error} = 1;                                                         # Raise error flag
    return( undef );                                                                          # Return on error
  }
  return( $Document );
}


sub _compile {
  # This private method compiles the XML document's associated DTD.
  # Calls:
  #    none
  # Parameters Required:
  #    Validator
  # Result Returned:
  #    true || undef
  # Example:
  #    method call
  my $Validator    = shift;                                               # Get Validator
  my %args         = @_;                                                  # Get arguments
  my $PP           = $PREPROCESSOR->new( Debug => $Validator->{Debug} );  # Get new Preprocessor object
  my $preprocessed = $PP->preprocessor( XML => $Validator->{DTD} );       # Preprocess DTD into Symbol table
  if( ( defined $preprocessed ) && ( $preprocessed == 1 ) ) {
    my $DTD = $COMPILER->new( Debug   => $Validator->{Debug},             # Compile DTD object
                              Symbols => $PP->declarations() );
    if( defined $DTD ) {
      $Validator->{Compiled} = $DTD;                                      # Link to compiled DTD to Validator object
    } else {
      $Validator->{Flags}->{Error} = 1;                                   # Raise error flag
      return( undef );                                                    # Return on error
    }
  } else {
    $Validator->{Flags}->{Error} = 1;                                     # Raise error flag
    return( undef );                                                      # Return on error
  }
  return(1);                                                              # Return compiled DOM object
}


sub _execute {
  # This method validates the Document object against the DTD.
  # Calls:
  #    none
  # Parameters Required:
  #    Validator
  #    hash    {
  #              Node => $Node
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Validator  = shift;                                                                       # Get Validator
  my %args       = @_;                                                                          # Get arguments
  my $Document   = $args{Document};
  my $Traverser  = $DT->new();
  my $TreeWalker = $Traverser->createTreeWalker( Root                     => $Document,         # Create TreeWalker object
                                                 WhatToShow               => undef,
                                                 Filter                   => undef,
                                                 EntityReferenceExpansion => 0 );
  $TreeWalker->walkTree( Node     => $Document->lastChild(),                                    # Walk the Document tree
                         Callback => sub {
                           my $Node     = shift;
                           my $NodeName = $Node->nodeName();
                           if( ! $Validator->{Compiled}->validate( Node => $Node ) ) {          # Validate Node against DTD
                             # ERROR
                           }
                           return(1);
                         } );
  return(1);
}


sub getPublic {
  # This method fetches the DTD text from a PUBLIC URI.
  # Calls:
  #    none
  # Parameters Required:
  #    Validator
  #    hash    {
  #              URI => $URI
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Validator = shift;       # Get Validator
  my %args      = @_;          # Get arguments
  my $URI       = $args{URI};  #
  return(1);
}


sub getSystem {
  # This method fetches the DTD text from a SYSTEM URI.
  # Calls:
  #    none
  # Parameters Required:
  #    Validator
  #    hash    {
  #              URI => $URI
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Validator = shift;                              # Get Validator
  my %args      = @_;                                 # Get arguments
  my $URI       = $args{URI};                         # Fetch URI
  my $DTD       = "";                                 # Temp variable contains loaded DTD
  if( -e $URI ) {
    my $Load = NetSoup::Files::Load->new();           # Get new Load object
    if( ! $Load->load( Pathname => $URI,              # Load DTD file
                       Data     => \$DTD ) ) {
      print( qq(ERROR\tCannot open file "$URI"\n) );
      $Validator->{Flags}->{Error} = 1;               # Raise error flag
      return( undef );                                # Return on error
    } else {
      $Validator->{DTD} = \$DTD;                      # Associate DTD with object
    }
  } else {
    print( qq(ERROR\t"$URI" does not exist\n) );
    $Validator->{Flags}->{Error} = 1;                 # Raise error flag
    return( undef );                                  # Return on error
  }
  return(1);
}


__DATA__
