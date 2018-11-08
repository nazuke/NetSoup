#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser::DTD.pm v00.00.01a 12042000
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
#                This particular class compiles the preprocessed
#                declarations table into a DTD object.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       _compile    -  This private method compiles the Symbol table into a DTD object


package NetSoup::XML::Parser::DTD;
use strict;
use NetSoup::Core;
use NetSoup::XML::Parser::Errors;
@NetSoup::XML::Parser::DTD::ISA = qw( NetSoup::Core
                                      NetSoup::XML::Parser::Errors );
my $MODULE   = "DTD";
my %ERRORS   = ();
my %DECLTYPE = ( 1 => "ELEMENT_DECL",
                 2 => "ENTITY_DECL",
                 3 => "ATTLIST_DECL" );
while( <NetSoup::XML::Parser::DTD::DATA> ) {
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
  #    DTD
  #    hash    {
  #              Debug   => 0 | 1
  #              Symbols => \%Symbols
  #            }
  # Result Returned:
  #    DTD
  # Example:
  #    $DTD->initialise();
  my $DTD         = shift;              # Get Preprocessor object
  my %args        = @_;                 # Get arguments
  $DTD->{Debug}   = $args{Debug} || 0;  # Get debugging flag
  $DTD->{Symbols} = $args{Symbols};     # Get Symbol table
  $DTD->{Element} = {};                 # Element declarations
  $DTD->{Entity}  = {};                 # Entity declarations
  $DTD->{Attlist} = {};                 # Attribute list declarations
  $DTD->{Errors}  = {};
  $DTD->_compile();
  return( $DTD );
}


sub _compile {
  # This private method compiles the Symbol table into a DTD object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    Document
  # Example:
  #    my $DTD = $DTD->_compile();
  my $DTD  = shift;  # Get object
  my %args = @_;     # Get arguments
  $DTD->clearErr();  # Clear error messages
  foreach my $NodeName ( keys %{$DTD->{Symbols}} ) {        # Compile into DTD structures
    my $Symbol = $DTD->{Symbols}->{$NodeName};
  SWITCH: for( $Symbol->nodeType() ) {
      m/ELEMENT_DECL/ && do {
        $DTD->{Element}->{$NodeName} = $Symbol->nodeRegex();
        last SWITCH;
      };
      m/ENTITY_DECL/ && do {
        last SWITCH;
      };
      m/ATTLIST_DECL/ && do {
        last SWITCH;
      };
    }
  }

  # Perform entity variable substitution

  return(1);
}


sub validate {
  # This method disptaches a Node to the correct validation method.
  # Calls:
  #    none
  # Parameters Required:
  #    DTD
  #    hash    {
  #              Node => $Node
  #            }
  # Result Returned:
  #    DTD
  # Example:
  #    $DTD->validate( Node => $Node );
  my $DTD     = shift;                                               # Get object
  my %args    = @_;                                                  # Get arguments
  my $Node    = $args{Node};
  my $success = 0;                                                   # True indicates success
  SWITCH: for( $Node->nodeType() ) {
    m/ELEMENT_NODE/ && do {                                          # Validate Element Node
      my $Name = $Node->nodeName();
      if( ! exists $DTD->{Element}->{$Name} ) {                      # Node not defined in DTD
        $DTD->_error( Errors  => \%ERRORS,
                      Module  => $MODULE,
                      Line    => $Node->lineNumber(),
                      Code    => "0001",
                      String  => $Name,
                      Context => $Node->parentNode()->nodeName() );  #
        $DTD->{Flags}->{Error} = 1;                                  # Raise error flag
      } else {
        $success = $DTD->_element( Node => $Node );                  #
      }
      last SWITCH;
    };
    m/TEXT_NODE/ && do {                                             # Validate Text Node
      last SWITCH;
    };
  }
  return( $success );
}


sub _element {
  # This method disptaches a Node to the correct validation method.
  # Calls:
  #    none
  # Parameters Required:
  #    DTD
  #    hash    {
  #              Node => $Node
  #            }
  # Result Returned:
  #    DTD
  # Example:
  #    $DTD->validate( Node => $Node );
  my $DTD      = shift;                                               # Get object
  my %args     = @_;                                                  # Get arguments
  my $Node     = $args{Node};
  my $success  = 0;
  my $NodeName = $Node->nodeName();
  my $Regex    = $DTD->{Element}->{$NodeName};                        # Retrieve regex from compiled DTD
  my $pattern  = "";
  my $NodeList = $Node->childNodes();
  my $length   = $NodeList->nodeListLength();
  for( my $i = 0 ; $i <= $length ; $i++ ) {
    my $NodeType = $NodeList->item( Item => $i )->nodeType();
    NODETYPE: for( $NodeType ) {
      m/TEXT_NODE/ && do {
        $pattern .= '#PCDATA ';
        last NODETYPE;
      };
      m/CDATA_SECTION_NODE/ && do {
        $pattern .= "CDATA ";
        last NODETYPE;
      };
      m/ELEMENT_NODE/ && do {
        $pattern .= $NodeList->item( Item => $i )->nodeName() . " ";  #
        last NODETYPE;
      };
      m// && do {
        print( qq(No Check On "$NodeType"\n) );
        last NODETYPE;
      };
    }
  }
  $pattern =~ s/ $//;                                                 # Trim trailing space character
  if( $pattern !~ m/$Regex/ ) {                                       # Match pattern against regex
    $DTD->_error( Errors  => \%ERRORS,
                  Module  => $MODULE,
                  Line    => $Node->lineNumber(),
                  Code    => "0002",
                  String  => $NodeName,
                  Context => $Node->parentNode()->nodeName() );       #
    $DTD->{Flags}->{Error} = 1;                                       # Raise error flag
    return( undef );                                                  # Return on error
  }
  # Validate Attributes




  return(1);
}


sub _entity {
  # This method disptaches a Node to the correct validation method.
  # Calls:
  #    none
  # Parameters Required:
  #    DTD
  #    hash    {
  #              Node => $Node
  #            }
  # Result Returned:
  #    DTD
  # Example:
  #    $DTD->validate( Node => $Node );
  my $DTD  = shift;  # Get object
  my %args = @_;     # Get arguments
  my $Node = $args{Node};
  my $success = 0;
}


sub _attlist {
  # This method disptaches a Node to the correct validation method.
  # Calls:
  #    none
  # Parameters Required:
  #    DTD
  #    hash    {
  #              Node => $Node
  #            }
  # Result Returned:
  #    DTD
  # Example:
  #    $DTD->validate( Node => $Node );
  my $DTD  = shift;  # Get object
  my %args = @_;     # Get arguments
  my $Node = $args{Node};
  my $success = 0;
}


sub DESTROY {
  my $DTD         = shift;
  #warn( "DESTROYING $DTD\n" ) if( $DTD->{Debug} );
  $DTD->{Symbols} = undef;
  return(1);
}


__DATA__
0001  Undefined element __ in !!
0002  Element __ not allowed in !!
