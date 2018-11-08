#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser::Preprocessor::Symbol.pm v00.00.01b 12042000
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
#                This class manages Symbol objects.
#
#
#   Methods:
#       initialise       -  This method is the object initialiser for this class
#       nodeType         -  This method gets/sets the Symbol NodeType property
#       nodeValue        -  This method gets/sets the Symbol NodeValue property
#       nodeValueAppend  -  This method appends to the NodeValue property
#       nodeNamespace    -  This private method returns the namespace of a tag
#       nodeName         -  This private method returns the name of a tag
#       nodeEmpty        -  This method gets/sets the Symbol NodeEmpty property
#       nodeClosing      -  This method gets/sets the Symbol NodeClosing property
#       nodeAttributes   -  This method gets the Symbol attributes
#       nodeDoctype      -  This method gets the Doctype fields
#       lineNumber       -  This method gets/sets the Symbol LineNumber property
#       subparse         -  This method sub-parses the Symbol's contents
#       _spElement       -  This private method parses the element attributes
#       _spText          -  This private method sub-parses text nodes
#       _spEntities      -  This private method sub-parses entities in an XML string
#       _spDoctype       -  This private method parses the DOCTYPE tag


package NetSoup::XML::Parser::Preprocessor::Symbol;
use strict;
use NetSoup::XML::Parser::Errors;
@NetSoup::XML::Parser::Preprocessor::Symbol::ISA = qw( NetSoup::XML::Parser::Errors );
my $MODULE   = "Symbol";
my %ERRORS   = ();
my %NODETYPE = ( 1  => "ELEMENT_NODE",
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
while( <NetSoup::XML::Parser::Preprocessor::Symbol::DATA> ) {
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
  #    Symbol
  #    hash    {
  #              Debug       => 0 | 1
  #              NodeType    => NODETYPE
  #              NodeValue   => $NodeValue
  #              NodeEmpty   => 0 | 1
  #              NodeClosing => 0 | 1
  #              LineNumber  => $LineNumber
  #              ParseText   => "no" | "yes"
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Symbol = NetSoup::XML::Parser::Symbol->initialise();
  my $Symbol                          = shift;                          # Get object
  my %args                            = @_;                             # Get arguments
  $Symbol->{Debug}                    = $args{Debug}         || 0;      # Get debug flag
  $Symbol->{XML}->{NodeType}          = $args{NodeType}      || "";     # NodeType
  $Symbol->{XML}->{NodeValue}         = $args{NodeValue}     || "";     # NodeValue
  $Symbol->{NetSoup}->{Attributes}    = {};                             # NetSoup Specific : Attributes Structure
  $Symbol->{NetSoup}->{NodeEmpty}     = $args{NodeEmpty}     || 0;      # NetSoup Specific : Empty Node Flag
  $Symbol->{NetSoup}->{NodeClosing}   = $args{NodeClosing}   || 0;      # NetSoup Specific : Closing Node Flag
  $Symbol->{NetSoup}->{LineNumber}    = $args{LineNumber}    || 0;      # NetSoup Specific : Line number of tag
  $Symbol->{NetSoup}->{CaseSensitive} = $args{CaseSensitive} || "yes";  # Get Case Sensitivity flag
  $Symbol->{NetSoup}->{HTMLMode}      = $args{HTMLMode}      || "no";   # Operate in HTML mode
  $Symbol->{NetSoup}->{ParseText}     = $args{ParseText}     || "yes";  # Get ParseText flag
  $Symbol->{NetSoup}->{Entities}      = {};                             # Character entity translation table
  $Symbol->clearErr();                                                  # Clear error messages
  return( $Symbol );
}


sub nodeType {
  # This method gets/sets the Symbol NodeType property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ NodeType => $nodeType ]
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $nodeType = $Symbol->nodeType();
  my $Symbol = shift;                              # Get object
  my %args   = @_;                                 # Get arguments
  if( exists $args{NodeType} ) {                   # Check for argument
    $Symbol->{XML}->{NodeType} = $args{NodeType};  # Set property
  }
  return( $Symbol->{XML}->{NodeType} );            # Return property
}


sub nodeValue {
  # This method gets/sets the Symbol NodeValue property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ NodeValue => $nodeValue ]
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $nodeValue = $Symbol->nodeValue();
  my $Symbol = shift;                                # Get object
  my %args   = @_;                                   # Get arguments
  if( exists $args{NodeValue} ) {                    # Check for argument
    $Symbol->{XML}->{NodeValue} = $args{NodeValue};  # Set property
  }
  return( $Symbol->{XML}->{NodeValue} );             # Return property
}


sub nodeValueAppend {
  # This method appends to the NodeValue property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              NodeValue => $nodeValue
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $nodeValue = $Symbol->nodeValueAppend( NodeValue => $nodeValue );
  my $Symbol                  = shift;                                    # Get object
  my %args                    = @_;                                       # Get arguments
  $Symbol->{XML}->{NodeValue} = $Symbol->nodeValue() . $args{NodeValue};  # Set property
  return( $Symbol->{XML}->{NodeValue} );                                  # Return property
}


sub nodeNamespace {
  # This private method returns the namespace of a tag.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Symbol    = shift;                                                           # Get object
  my %args      = @_;                                                              # Get arguments
  my $tag       = $Symbol->nodeValue() || "";
  my $namespace = "";
  if( length( $tag ) > 0 ) {                                                       # Check for contents
    ( $namespace, undef ) = ( $tag =~ m"^\s*<[/!?]?([^:\s/>]+):([^\s/>]+)\s?"s );  # Parse XML tag name component
  }
  if( ( defined $namespace ) && ( exists $args{NodeNamespace} ) ) {
    $tag =~ s/^<(\/?)\Q$namespace\E:/<$1$args{NodeNamespace}:/;
    $Symbol->nodeValue( NodeValue => $tag );
    $namespace = $Symbol->nodeNamespace();
  }
  return( $namespace || "" );                                                      # Return XML tag name
}


sub nodeName {
  # This private method returns the name of a tag.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Symbol  = shift;                                                            # Get object
  my %args    = @_;                                                               # Get arguments
  my $tag     = $Symbol->nodeValue() || "";
  my $tagname = "";
  if( length( $tag ) > 0 ) {                                                      # Check for contents
    ( undef, $tagname ) = ( $tag =~ m"^\s*<[/!?]?([^:\s/>]+:)?([^\s/>]+)\s?"s );  # Parse XML tag name component
  }
  if( ( defined $tagname ) && ( exists $args{NodeName} ) ) {
    $tag =~ s/^(<\/?([^:]+:)?)\Q$tagname\E/$1$args{NodeName}/;
    $Symbol->nodeValue( NodeValue => $tag );
    $tagname = $Symbol->nodeName();
  }
  return( $tagname || "" );                                                       # Return XML tag name
}


sub nodeEmpty {
  # This method gets/sets the Symbol NodeEmpty property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ NodeEmpty => $nodeEmpty ]
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $nodeEmpty = $Symbol->nodeEmpty();
  my $Symbol = shift;                                    # Get object
  my %args   = @_;                                       # Get arguments
  if( exists $args{NodeEmpty} ) {                        # Check for argument
    $Symbol->{NetSoup}->{NodeEmpty} = $args{NodeEmpty};  # Set property
  }
  return( $Symbol->{NetSoup}->{NodeEmpty} );             # Return property
}


sub nodeClosing {
  # This method gets/sets the Symbol NodeClosing property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ NodeClosing => $nodeClosing ]
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $nodeClosing = $Symbol->nodeClosing();
  my $Symbol = shift;                                        # Get object
  my %args   = @_;                                           # Get arguments
  if( exists $args{NodeClosing} ) {                          # Check for argument
    $Symbol->{NetSoup}->{NodeClosing} = $args{NodeClosing};  # Set property
  }
  return( $Symbol->{NetSoup}->{NodeClosing} );               # Return property
}


sub nodeAttributes {
  # This method gets the Symbol attributes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar
  # Example:
  #    my $nodeAttributes = $Symbol->nodeAttributes();
  my $Symbol = shift;                          # Get object
  my %args   = @_;                             # Get arguments
  return( $Symbol->{NetSoup}->{Attributes} );  # Return hash reference of attributes
}


sub nodeDoctype {
  # This method gets the Doctype fields.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    hashref
  # Example:
  #    my $fields = $Symbol->nodeDoctype();
  my $Symbol = shift;                       # Get object
  my %args   = @_;                          # Get arguments
  return( $Symbol->{NetSoup}->{DOCTYPE} );  # Return hash reference of Doctype fields
}


sub entities {
  # This method gets/sets the character entity translation table.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ LineNumber => $lineNumber ]
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $lineNumber = $Symbol->lineNumber();
  my $Symbol = shift;                                  # Get object
  my %args   = @_;                                     # Get arguments
  if( exists $args{Entities} ) {                       # Check for argument
    $Symbol->{NetSoup}->{Entities} = $args{Entities};  # Set property
  }
  return( $Symbol->{NetSoup}->{Entities} );            # Return property
}


sub lineNumber {
  # This method gets/sets the Symbol LineNumber property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ LineNumber => $lineNumber ]
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $lineNumber = $Symbol->lineNumber();
  my $Symbol = shift;                                      # Get object
  my %args   = @_;                                         # Get arguments
  if( exists $args{LineNumber} ) {                         # Check for argument
    $Symbol->{NetSoup}->{LineNumber} = $args{LineNumber};  # Set property
  }
  return( $Symbol->{NetSoup}->{LineNumber} );              # Return property
}


sub subparse {
  # This method sub-parses the Symbol's contents.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar
  # Example:
  #    my $lineNumber = $Symbol->lineNumber();
  my $Symbol = shift;                                                        # Get object
  my %args   = @_;                                                           # Get arguments
  if( $Symbol->{Debug} ) {
    print( STDERR qq(\t\tSYMBOL VALUE "$Symbol->{XML}->{NodeValue}"\n) );
  }
 TYPE: for( $Symbol->{XML}->{NodeType} ) {

    m/ELEMENT_NODE/ && do {
      my $attributes = $Symbol->_spElement();
      if( defined $attributes ) {
        foreach my $name ( keys %{$attributes} ) {
          my $newname = $name;
          $newname    = lc( $name )
            if( $Symbol->{NetSoup}->{CaseSensitive} eq "no" );
          $Symbol->{NetSoup}->{Attributes}->{$newname} = $attributes->{$name};  #
        }
      } else {
        return( undef );
      }
      last TYPE;
    };

    m/TEXT_NODE/ && do {
      if( $Symbol->{NetSoup}->{ParseText} eq "yes" ) {
        return( undef ) if( ! $Symbol->_spText( %args ) );
      }
      last TYPE;
    };

    m/ENTITY_REFERENCE_NODE/ && do {
      last TYPE;
    };

    m/ENTITY_NODE/ && do {
      last TYPE;
    };

    m/PROCESSING_INSTRUCTION_NODE/ && do {
      last TYPE;
    };

    m/DOCUMENT_TYPE_NODE/ && do {
      my $doctype = $Symbol->_spDoctype();
      foreach my $field ( keys %{$doctype} ) {
        $Symbol->{NetSoup}->{DOCTYPE}->{$field} = $doctype->{$field};  #
      }
      last TYPE;
    };

    m/NOTATION_NODE/ && do {
      last TYPE;
    };

    print( STDERR qq(NODETYPE\t"$_" not supported\n) ); # DEBUG

  }
  return(1);
}


sub _spElement {
  # This private method parses the element attributes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    hash reference
  # Example:
  #    my %attributes = $Symbol->_spElement();
  my $Symbol = shift;
  my %args   = @_;
  my %state  = ( Key     => 1,
                 SglQuot => 0,
                 DblQuot => 0 );
  my %attrib = ();
  my @chars  = split( //, $Symbol->{XML}->{NodeValue} );
  my $Key    = "";                                                # String of current key
  my $i      = 0;
  if( ( $chars[0] =~ m/[^<]/ ) || ( $chars[-1] =~ m/[^>]/ ) ) {   # Check for missing <> characters
    $Symbol->_error( Errors => \%ERRORS,                          # Generate error message
                     Module => $MODULE,
                     Line   => $Symbol->lineNumber(),
                     Code   => "0001",
                     String => $Key,
                     Sample => $Symbol->nodeValue() );
    return( undef );
  }
 PREAMBLE: for( $i = 0 ; $i <= ( @chars - 1 ) ; $i++ ) {          # Parse characters
    last PREAMBLE if( $chars[$i] =~ m/[ \t\x0A\x0D]/gis );
  }
 CHARS: for( $i = $i ; $i <= ( @chars - 1 ) ; $i++ ) {            # Parse characters
  VECT: for( $chars[$i] ) {                                       # Switch
      my $w_char = '[\x2D\w\d_:\.]';                              # Word character pattern
      # Word Character
      m/$w_char/gs && do {
        if( $state{Key} == 1 ) {
          $Key .= $chars[$i];
        NEXT: for( $chars[$i+1] ) {                               # Detect malformed attributes
            m/=/ && do {                                          # End of attribute name
              $state{Key} = 0;
              $i++;
              last NEXT;
            };
            m/$w_char/ && do {                                    # Next attribute name character
              last NEXT;
            };
            m/[ \t\/>]/ &&
              ( $Symbol->{NetSoup}->{HTMLMode} eq "yes" ) &&
                do {                                              # Accept HTML attributes
                  $attrib{$Key} .= "1";
                  $state{Key}    = 1;
                  $i++;
                  last NEXT;
                };
            m/./ && do {                                          # Unexpected character
              $Symbol->_error( Errors => \%ERRORS,                # Generate error message
                               Module => $MODULE,
                               Line   => $Symbol->lineNumber(),
                               Code   => "0002",
                               String => $Key,
                               Sample => $Symbol->nodeValue() );
              return( undef );
            };
          }
        } else {
          $attrib{$Key} .= $chars[$i];
        }
        last VECT;
      };
      # Single Quote
      m/\'/gis && do {
        for( $i = $i + 1 ; $i <= ( @chars - 1 ) ; $i++ ) {        # Parse characters
          if( $chars[$i] eq "\'" ) {
            $state{Key} = 1;
            $Key        = "";
            last VECT;
          } else {
            $attrib{$Key} .= $chars[$i];
          }
        }
        last VECT;
      };
      # Double Quote
      m/\"/gis && do {
        for( $i = $i + 1 ; $i <= ( @chars - 1 ) ; $i++ ) {        # Parse characters
          if( $chars[$i] eq '"' ) {
            $state{Key} = 1;
            $Key        = "";
            if( $chars[$i+1] !~ m/[ \t\x0A\x0D>\/]/gis ) {
              $Symbol->_error( Errors => \%ERRORS,                # Generate error message
                               Module => $MODULE,
                               Line   => $Symbol->lineNumber(),
                               Code   => "0012",
                               String => $chars[$i],
                               Sample => $Symbol->nodeValue() );
              #return( undef ); # Ignore this error
            }
            last VECT;
          } else {
            $attrib{$Key} .= $chars[$i];
          }
        }
        last VECT;
      };


      # Whitespace
      m/[ \t\x0A\x0D]/gis && do {
        if( ( $state{Key} == 0 ) &&
            ( $state{SglQuot} || $state{DblQuot} == 1 ) ) {       #
          $attrib{$Key} .= $chars[$i];
        } elsif( $Symbol->{NetSoup}->{HTMLMode} eq "yes" ) {
          $state{Key} = 1;
          $Key        = "";
        }
        last VECT;
      };


      # Slash
      m/\//gis && do {
        if( ( $state{Key} == 0 ) &&
            ( $Symbol->{NetSoup}->{HTMLMode} eq "yes" ) ){
          $state{Key} = 1;
          $Key        = "";
          last CHARS;
        }
        elsif( $state{Key} == 0 ) {
          $attrib{$Key} .= $chars[$i];
        }
        last VECT;
      };


      # Right Angle-Bracket
      m/>/gis && do {
        if( $state{Key} == 0 ) {
          $attrib{$Key} .= $chars[$i];
        }
        last VECT;
      };




      # Quoteless Attribute Value
      m/./gis && do {
        if( ( $state{Key} == 0 ) &&
            ( $Symbol->{NetSoup}->{HTMLMode} eq "yes" ) ){
          $attrib{$Key} .= $chars[$i];
        }
        last VECT;
      };





      # Any Character
      m/./gis && do {
        if( $state{Key} == 1 ) {
          $Key .= $chars[$i];
        } else {
          $attrib{$Key} .= $chars[$i];
        }
        last VECT;
      };
    }
  }
  return( \%attrib );
}


sub _spText {
  # This private method sub-parses text nodes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    {}
  # Example:
  #    my $result = $Symbol->_spText();
  my $Symbol   = shift;                                          # Get Symbol object
  my %args     = @_;                                             # Get arguments
  my $Entities = $args{Entities} || undef;
  my $text     = $Symbol->nodeValue();                           # Extract copy of Node value
  my $sp       = $Symbol->_spEntities( Text     => \$text,       # Sub-parse character entities
                                       Entities => $Entities );
  foreach my $char ( split( m//, $text ) ) {
    if( $char =~ m/[\x7F-\xFF]/ ) {
      $Symbol->_error( Errors  => \%ERRORS,                      # Generate error message
                       Module  => $MODULE,
                       Line    => $Symbol->lineNumber(),
                       Code    => "0013",
                       String  => $char,
                       Context => $Symbol->nodeType(),
                       Sample  => $Symbol->nodeValue() );
      return( undef );
    }
  }
  return( $sp );
}


sub _spEntities {
  # This private method sub-parses entities in an XML string.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    {}
  # Example:
  #    my $result = $Symbol->_spEntities( Text => \$text);
  my $Symbol   = shift;                                            # Get Symbol object
  my %args     = @_;                                               # Get arguments
  my $text     = $args{Text};                                      # Get XML string reference
  my $Entities = $args{Entities} || undef;
  my %state    = ( Entity => 0,                                    # Processor state
                   Value  => "" );
  my %entities = ();                                               # Entity transformation table
  my @chars    = split( //, $$text );                              # Replace this with ARRAYSTRING
  for( my $i = 0 ; $i <= ( @chars - 1 ) ; $i++ ) {                 # Process characters
    SWITCH: for( $chars[$i] ) {
      # Begin Entity
      m/[&]/ && do {
        if( $state{Entity} ) {
          $Symbol->_error( Errors  => \%ERRORS,                    # Generate error message
                           Module  => $MODULE,
                           Line    => $Symbol->lineNumber(),
                           Code    => "0003",
                           String  => $state{Value},
                           Context => $Symbol->nodeType(),
                           Sample  => $Symbol->nodeValue() );
          return( undef );
        } else {
          $state{Entity} = 1;
          $state{Value}  = $chars[$i];
        }
        last SWITCH;
      };
      # Terminate Entity
      m/;/ && do {
        if( $state{Entity} ) {
          $state{Entity}           = 0;
          $state{Value}           .= $chars[$i];
          $entities{$state{Value}} = 1;
          $Symbol->{NetSoup}->{Entities}->{$state{Value}} = 1;     # Store entity in character entity table
          if( defined $Entities ) {                                # Validate entity if Entities table supplied
            if( ! exists $Entities->{$state{Value}} ) {
              $Symbol->_error( Errors  => \%ERRORS,                # Generate error message
                               Module  => $MODULE,
                               Line    => $Symbol->lineNumber(),
                               Code    => "0004",
                               String  => $state{Value},
                               Context => $Symbol->nodeType(),
                               Sample  => $Symbol->nodeValue() );  #
              return( undef );
            }
          }
        } else {
          $Symbol->_warning( Errors  => \%ERRORS,                  # Generate warning message
                             Module  => $MODULE,
                             Line    => $Symbol->lineNumber(),
                             Code    => "0011",
                             String  => $state{Value},
                             Context => $Symbol->nodeType(),
                             Sample  => $Symbol->nodeValue() );
        }
        last SWITCH;
      };
      # Errors
      m/\s/ && do {
        if( $state{Entity} ) {
          $Symbol->_error( Errors  => \%ERRORS,                    # Generate error message
                           Module  => $MODULE,
                           Line    => $Symbol->lineNumber(),
                           Code    => "0003",
                           String  => $state{Value},
                           Context => $Symbol->nodeType(),
                           Sample  => $Symbol->nodeValue() );
          return( undef );
        }
        # Fall Through...
      };
      # Default
      m/./ && do {
        if( $state{Entity} ) {
          $state{Value} .= $chars[$i];
        }
        last SWITCH;
      };
    }
  }
  if( $state{Entity} ) {                                           # Runaway entity found
    $Symbol->_error( Errors  => \%ERRORS,                          # Generate error message
                     Module  => $MODULE,
                     Line    => $Symbol->lineNumber(),
                     Code    => "0005",
                     String  => $state{Value},
                     Context => $Symbol->nodeType(),
                     Sample  => $Symbol->nodeValue() );
    return( undef );
  }
  return(1);
}


sub _spDoctype {
  # This private method parses the DOCTYPE tag.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    {}
  # Example:
  #    my %doctype = $Symbol->_spDoctype();
  my $Symbol   = shift;
  my %args     = @_;
  my %doctype  = ( Root => "",
                   ID   => "",
                   Name => "",
                   URI  => "" );
  my ( $copy ) = ( $Symbol->{XML}->{NodeValue} =~ m/^[<]!DOCTYPE\s+([^>]+)[>]$/i );
  my @fields   = split( m/\s+/, $copy );
 SWITCH: for( scalar @fields ) {
    m/3/ && do {
      $doctype{Root}    =   $fields[0];
      $doctype{ID}      =   $fields[1];
      ( $doctype{URI} ) = ( $fields[2] =~ m/^\"([^\"]+)\"$/ );
      last SWITCH;
    };
    m/4/ && do {
      $doctype{Root}    =   $fields[0];
      $doctype{ID}      =   $fields[1];
      $doctype{Name}    =   $fields[2];
      ( $doctype{URI} ) = ( $fields[2] =~ m/^\"([^\"]+)\"$/ );
      last SWITCH;
    };
    m// && do {
      print( STDERR "ERROR\n" );
      last SWITCH;
    };
  }
  return( \%doctype );
}


sub DESTROY {
  my $Symbol = shift;
  return(1);
}


__DATA__
0001  Expecting angle-bracket in tag __
0002  Expecting "=" after attribute name __
0003  Expecting semi-colon in entity __ in !!
0004  Undefined entity __ in !!
0005  Expecting semi-colon in entity __ in !!
0006  Expecting opening double quote near __
0007  Expecting closing double quote near __
0008  Expecting opening single quote near __
0009  Expecting closing single quote near __
0010  Illegal character in entity __ in !!
0011  Semi-colon used outside character entity
0012  Expecting whitespace after __ character
0013  Illegal character  __ in !!
