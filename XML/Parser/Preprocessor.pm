#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser::Preprocessor.pm v00.00.01b 12042000
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
#                This class is parses XML text into a Symbol table ready
#                for compilation.
#                This class currently only parses out XML tags and data, other
#                types of data, such as style sheets and scripts are left intact.
#
#
#   Methods:
#       initialise     -  This method is the object initialiser for this class
#       preprocessor   -  This method bootstraps the preprocessing procedure
#       _normalize     -  This private method prepares the raw XML data for parsing
#       _preprocessor  -  This private method parses raw XML data into an array of tags and data
#       _state         -  This private method inspects the state machine for inconsistencies
#       _compactDecl   -  This private method compacts the Declarations table
#       _compactSyms   -  This private method compacts the Symbol table
#       _orphans       -  This private method scans the Symbol table for orphaned closing tags
#       _balance       -  This private method scans the Symbol table for unbalanced tags
#       declarations   -  This method returns the Declarations table as an array reference
#       symbols        -  This method returns the Symbol table as an array reference
#       entities       -  This method returns the character entities from all of the Symbols


package NetSoup::XML::Parser::Preprocessor;
use strict;
#eval( "use Thread;" );  # Eval'ed for non-threading Perl's
use English;
use NetSoup::Core;
use NetSoup::XML::Parser::Preprocessor::ArrayString;
use NetSoup::XML::Parser::Preprocessor::QuoteStack;
use NetSoup::XML::Parser::Preprocessor::Declaration;
use NetSoup::XML::Parser::Preprocessor::Symbol;
use NetSoup::XML::Parser::Errors;
@NetSoup::XML::Parser::Preprocessor::ISA = qw( NetSoup::Core
                                               NetSoup::XML::Parser::Errors );
my $MODULE      = "Preprocessor";
my %ERRORS      = ();
my $ARRAYSTRING = "NetSoup::XML::Parser::Preprocessor::ArrayString";
my $QUOTESTACK  = "NetSoup::XML::Parser::Preprocessor::QuoteStack";
my $DECLARATION = "NetSoup::XML::Parser::Preprocessor::Declaration";
my $SYMBOL      = "NetSoup::XML::Parser::Preprocessor::Symbol";
my %DECLTYPE    = ( 1  => "ELEMENT_DECL",
                    2  => "ENTITY_DECL",
                    3  => "ATTLIST_DECL" );
my %NODETYPE    = ( 1  => "ELEMENT_NODE",
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
while( <NetSoup::XML::Parser::Preprocessor::DATA> ) {
  chomp;
  last if( ! length );
  my( $key, $value ) = split( /\t+/ );
  $ERRORS{$key}      = $value;
}
1;


sub BEGIN {}


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  #    hash    {
  #              Debug         => 0 | 1
  #              Entities      => \%Entities
  #              Empty         => \@Empty
  #              Strict        => 
  #              CaseSensitive => 
  #              HTMLMode      => 
  #              Orphans       => 
  #              ParseText     => 
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Preprocessor->initialise();
  my $Preprocessor               = shift;                          # Get Preprocessor
  my %args                       = @_;                             # Get arguments
  my $Entities                   = $args{Entities}      || {};     # Get Entities table reference
  my $Empty                      = $args{Empty}         || [];     # Get Empty element list reference
  $Preprocessor->{Debug}         = $args{Debug}         || 0;      # Get debugging flag
  $Preprocessor->{Strict}        = $args{Strict}        || "yes";  # Get Strict XML flag
  $Preprocessor->{CaseSensitive} = $args{CaseSensitive} || "yes";  # Get Case Sensitivity flag
  $Preprocessor->{HTMLMode}      = $args{HTMLMode}      || "no";   # Operate in HTML mode
  $Preprocessor->{Orphans}       = $args{Orphans}       || 0;      # Get Orphan checking flag
  $Preprocessor->{ParseText}     = $args{ParseText}     || "yes";  # Get ParseText flag
  $Preprocessor->{Declarations}  = {};                             # Initialise Declarations table
  $Preprocessor->{Symbols}       = [];                             # Initialise Symbol table
  if( keys( %{$Entities} ) > 0 ) {
    $Preprocessor->{Entities} = \%{$Entities};                     # Get Entities table reference
  } else {
    $Preprocessor->{Entities} = undef;                             # Undefine Entities table reference
  }
  if( @{$Empty} > 0 ) {
    $Preprocessor->{Empty} = \@{$Empty};                           # Get Empty element list reference
  } else {
    $Preprocessor->{Empty} = [];                                   # Clear element list reference
  }
  return( $Preprocessor );
}


sub preprocessor {
  # This method bootstraps the preprocessing procedure.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              XML        => \$XML
  #              Whitespace => "preserve" || "compact"
  #              Callback   => sub {}
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $success = $Preprocessor->preprocessor();
  my $Preprocessor = shift;                                               # Get Preprocessor
  my %args         = @_;                                                  # Get arguments
  $Preprocessor->clearErr();                                              # Clear error messages
  $Preprocessor->_normalize( XML => $args{XML} );                         # Prepare raw XML data for parsing
  if( ! defined $Preprocessor->_preprocessor( %args ) ) {                 # Bootstrap
  ERRORS: foreach my $Symbol ( @{$Preprocessor->{Symbols}} ) {
      last ERRORS if( ! defined $Symbol );
      $Preprocessor->{Errors}->{Count} += $Symbol->count();               # Increment error count
      push( @{$Preprocessor->{Errors}->{Messages}}, $Symbol->errors() );  # Gather error messages
      push( @{$Preprocessor->{Errors}->{Types}}, $Symbol->types() );      # Gather error types
      push( @{$Preprocessor->{Errors}->{Samples}}, $Symbol->samples() );  # Gather error samples
    }
    $Preprocessor->{Symbols} = [];                                        # Purge Symbol table
    return( undef );
  }
  return(1);
}


sub _normalize {
  # This private method prepares the raw XML data for parsing.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  # Result Returned:
  #    boolean
  # Example:
  #    $Preprocessor->_normalize( XML => \$XML );
  my $Preprocessor = shift;                             # Get Preprocessor
  my %args         = @_;                                # Get arguments
  my $XML          = $args{XML};
  $$XML            =~ s/([\x0D][\x0A]|[\x0D])/\x0A/gs;  # Normalize line endings to Unix \n format
  return(1);
}


sub _preprocessor {
  # This private method parses raw XML data into an array of tags and data.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              XML        => \$XML
  #              Whitespace => "preserve" || "compact"
  #              Callback   => sub {}
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $success = $Preprocessor->preprocessor();
  my $Preprocessor = shift;                                                                     # Get Preprocessor
  my %args         = @_;                                                                        # Get arguments
  my $XML          = $args{XML}        || return( undef );
  my $whitespace   = $args{Whitespace} || "compact";                                            # Preserve or compact whitespace
  my $callback     = $args{Callback}   || undef;                                                # Callback to execute during preprocessing
  my $DECLS        = [];                                                                        # Initialise Declarations list
  my $SYMBOLS      = $Preprocessor->{Symbols} = [];                                             # Re-initialise Symbol table
  my $Entities     = $Preprocessor->{Entities};                                                 # Get Entities table reference
  my @CHARS        = ();                                                                        # Empty array is tied
  my $tied         = undef;
 SYSTEM: for( $OSNAME ) {
    m/^mac/i && do {
      @CHARS = split( //, $$XML );                                                              # Tied arrays unimplemented on Mac
      last SYSTEM;
    };
    m/./i && do {
      $tied = tie( @CHARS, $ARRAYSTRING,                                                        # Tie string to array class
                   Data  => $XML,
                   Debug => $Preprocessor->{Debug} );
      last SYSTEM;
    };
  }
  my %state    = ( LineNo       => 1,                                                           # Structure monitors processor state
                   InTag        => 0,
                   InAttrVal    => 0,
                   InSglQuot    => 0,
                   InSglQuotSym => undef,
                   InDblQuot    => 0,
                   InDblStack   => [],
                   InDblCount   => 0,
                   InDblQuotSym => undef );
  my $dbltied  = tie( $state{InDblQuot}, $QUOTESTACK,
                      Stack => $state{InDblStack},
                      Count => $state{InDblCount},
                      Ref   => \$state{LineNo} );
  my $inQuotes = sub { return $state{InSglQuot} + $state{InDblQuot} };                          # Closure for checking quote state
  my $cursor   = 0;                                                                             # Pointer to current character being processed
  my $i        = 0;
  print( STDERR "\tPreprocessing\n" ) if( $Preprocessor->{Debug} );
  eval {
    my $Watchman = new Thread( sub {                                                            # Percentage done thread
                                 my $counter = shift;
                                 my $size    = @CHARS;
                                 my $percent = $size / 100;
                                 while( $$counter <= $size ) {
                                   my $percentage = int( $$counter / $percent );
                                   if( defined $callback ) {
                                     &$callback( Module     => $MODULE,
                                                 Percentage => $percentage );
                                   }
                                   return(1) if( $Preprocessor->errors() );
                                   sleep(1);
                                 }
                                 return(1);
                               }, \$i );
    $Watchman->detach();
  };
  $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},                  # Initialise new Symbol
                                      NodeType      => $NODETYPE{3},
                                      LineNumber    => $state{LineNo},
                                      CaseSensitive => $Preprocessor->{CaseSensitive},
                                      HTMLMode   => $Preprocessor->{HTMLMode},
                                      ParseText     => $Preprocessor->{ParseText} );
  print( STDERR "\t\t" . scalar(@CHARS) . " Characters\n" ) if( $Preprocessor->{Debug} );        # DEBUG
 CHARS: for( $i = 0 ; $i < @CHARS ; $i++ ) {                                                    # Parse characters into array structure
    my $CC = $CHARS[$i];                                                                        # Store current character - Accelerates ArrayString
    if( defined $tied ) {                                                                       # Check for out of data condition
      if( $tied->_error() ) {
        $Preprocessor->_error( Errors  => \%ERRORS,                                             # Generate error message
                               Module  => $MODULE,
                               State   => \%state,
                               Symbol  => $SYMBOLS->[$cursor]->nodeValue(),
                               Line    => $state{LineNo},
                               Code    => "0008",
                               String  => $CC,
                               Context => $SYMBOLS->[$cursor]->nodeType(),
                               Sample  => $Preprocessor->_sample( Array  => \@CHARS,
                                                                  Cursor => $i ) );
        $i = @CHARS + 1;
        undef $tied;
        untie @CHARS;
        return( undef );                                                                        # Return on error
      }
    }
    ###############################################
    # Note:                                       #
    # The ordering of the following switch cases  #
    # is important when determing the precedence  #
    # of each character being processed           #
    ###############################################
  VECT: for( $CC ) {                                                                            # Direct into character processing function


      # Line Feed
      m/[\x0A]/ && do {
        $state{LineNo}++;                                                                       # Increment line number
        $CC = " ";                                                                              # Convert line feed to space character
        #last VECT if( $whitespace =~ m/^compact$/i );                                          # Continue if whitespace must be preserved
        # Fall Through...
      };


      # Tag Start
      m/[<]/ && do {
        if( &$inQuotes() ) {                                                                    # Am I inside quotes ?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT;
        } else {
          if( $state{InTag} ) {
            my ( $fragment ) = ( $SYMBOLS->[$cursor]->nodeValue() =~ m/^(<[^\s]+)\s?/ );
            $Preprocessor->_error( Errors  => \%ERRORS,                                         # Generate error message
                                   Module  => $MODULE,
                                   Line    => $SYMBOLS->[$cursor]->lineNumber(),
                                   Code    => "0001",
                                   String  => $fragment,
                                   Context => $SYMBOLS->[$cursor]->nodeType(),
                                   Sample  => $SYMBOLS->[$cursor]->nodeValue() );
            return( undef );
          }
        }
        $cursor++;                                                                              # Increment Symbol element pointer
        $SYMBOLS->[$cursor] = $SYMBOL->new( Debug      => $Preprocessor->{Debug},               # Initialise new Symbol
                                            NodeType   => $NODETYPE{3},
                                            LineNumber => $state{LineNo},
                                            CaseSensitive => $Preprocessor->{CaseSensitive},
                                            HTMLMode   => $Preprocessor->{HTMLMode},
                                            ParseText     => $Preprocessor->{ParseText} );
        if( $state{InTag} ) {                                                                   # Inside tag
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT;
        } else {
          $state{InTag} = 1;                                                                    # Enter in tag state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{1} );                            # Flag Symbol as an XML element tag
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT;
        }
      };


      # Tag Stop
      m/[>]/ && do {
        if( &$inQuotes() ) {                                                                    # Am I inside quotes ?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT;
        }
        if( $state{InTag} ) {                                                                   # Am I inside a tag ?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          if( ! $SYMBOLS->[$cursor]->nodeClosing() ) {                                          # Sub-parse Symbol contents
            $SYMBOLS->[$cursor]->subparse( Entities => $Entities ) || return( undef );
            if( @{$Preprocessor->{Empty}} > 0 ) {                                               # Hack for empty elements
              EMPTY: foreach my $empty ( @{$Preprocessor->{Empty}} ) {
                if( $SYMBOLS->[$cursor]->nodeName() eq $empty ) {
                  $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                             # Flag Symbol as empty tag
                  last EMPTY;
                }
              }
            }
          }
          $state{InTag} = 0;                                                                    # Leave tag state
          $cursor++;                                                                            # Increment Symbol element pointer
          $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},          # Initialise new Symbol
                                              NodeType      => $NODETYPE{3},
                                              LineNumber    => $state{LineNo},
                                              CaseSensitive => $Preprocessor->{CaseSensitive},
                                              HTMLMode   => $Preprocessor->{HTMLMode},
                                              ParseText     => $Preprocessor->{ParseText} );
        } else {
          if( $Preprocessor->{Strict} eq "yes" ) {                                              # Operating under Strict XML
            $Preprocessor->_error( Errors  => \%ERRORS,                                         # Generate error message
                                   Module  => $MODULE,
                                   State   => \%state,
                                   Symbol  => $SYMBOLS->[$cursor]->nodeValue(),
                                   Line    => $state{LineNo},
                                   Code    => "0002",
                                   String  => $CC,
                                   Context => $SYMBOLS->[$cursor]->nodeType(),
                                   Sample  => $Preprocessor->_sample( Array  => \@CHARS,
                                                                      Cursor => $i ) );
            return( undef );                                                                    # Return on error
          } else {                                                                              # SGML Sloppy
            $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );
          }
        }
        last VECT;
      };
      
      
      # Closing Tag / End of Empty Tag
      m/[\/]/ && do {
        if( &$inQuotes() ) {                                                                    # Am I inside quotes ?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT;
        }
        if( $state{InTag} ) {                                                                   # Am I inside a tag ?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          if( ($CHARS[$i-1] eq "<") && ($CHARS[$i+1] ne ">") ) {                                # Confirm closing tag
            $i++; $CC = $CHARS[$i];
            $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{1} );                          # Flag Symbol XML element tag
            $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                           # Append character to Symbol
            $SYMBOLS->[$cursor]->nodeClosing( NodeClosing => 1 );                               # Flag Symbol as closing XML element tag
            last VECT;
          }
          if( $CHARS[$i+1] eq ">" ) {                                                           # Check for closing angle bracket
            $state{InTag} = 0;                                                                  # Leave tag state
            $i++; $CC = $CHARS[$i];
            $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                           # Append character to Symbol
            $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                                   # Flag Symbol as empty tag
            $SYMBOLS->[$cursor]->subparse( Entities => $Entities ) || return( undef );
            $cursor++;                                                                            # Increment Symbol element pointer
            $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},          # Initialise new Symbol
                                                NodeType      => $NODETYPE{3},
                                                LineNumber    => $state{LineNo},
                                                CaseSensitive => $Preprocessor->{CaseSensitive},
                                                HTMLMode      => $Preprocessor->{HTMLMode},
                                                ParseText     => $Preprocessor->{ParseText} );
            last VECT;
          }
        }
        # Fall Through...
      };











=pod
      # Script Element
      m/[s]/i && ( $Preprocessor->{HTMLMode} eq "yes" ) && do {
        if( ( $CHARS[$i-1] eq "<" ) && ( join("",@CHARS[$i+1..$i+5]) =~ m/cript/i ) ) {          # Check for start of comment
          $state{InTag} = 0;                                                                    # Leave tag state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{1} );                            # Flag Symbol as an XML comment tag
          $i += 5;                                                                              # Adjust character pointer
          print( STDERR "$CHARS[$i]\n" );
          $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},         # Initialise new Symbol
                                              NodeType      => $NODETYPE{3},
                                              LineNumber    => $state{LineNo},
                                              CaseSensitive => $Preprocessor->{CaseSensitive},  #
                                              HTMLMode      => $Preprocessor->{HTMLMode},
                                              ParseText     => "no" );
        CMT: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                     # Load rest of comment
            $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                                     # Increment line number
            if( join("",@CHARS[$i+1..$i+9]) =~ m:</script>:i ) {                                 # Check for script terminator
              $cursor++;                                                                        # Increment Symbol element pointer
              $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},         # Initialise new Symbol
                                                  NodeType      => $NODETYPE{1},
                                                  NodeValue     => "</script>",
                                                  NodeClosing   => 1,
                                                  LineNumber    => $state{LineNo},
                                                  CaseSensitive => $Preprocessor->{CaseSensitive},  #
                                                  HTMLMode      => $Preprocessor->{HTMLMode},
                                                  ParseText     => "no" );
              last CMT;
            } else {
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
            }
          }
          last VECT;
        }
        # Fall Through...
      };
=cut

















      # Bare Exclamation Mark
      m/[!]/ && do {
        if( &$inQuotes() ) {                                                                    # Am I inside quotes ?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT;
        }
        # Fall Through...
      };


      # XML Comment
      m/[!]/ && do {
        if( ( $CHARS[$i-1] eq "<" ) && ( "$CHARS[$i+1]$CHARS[$i+2]" eq "--" ) ) {               # Check for start of comment
          $state{InTag}                              = 0;                                       # Leave tag state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{8} );                            # Flag Symbol as an XML comment tag
          $SYMBOLS->[$cursor]->nodeValue( NodeValue => "" );                                    # Append character to Symbol
          $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                                     # Flag Symbol as empty tag
          $i += 3;                                                                              # Adjust character pointer
        CMT: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                     # Load rest of comment
            $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                                     # Increment line number
            if( ( $CHARS[$i]   eq "-" ) &&                                                      # Check for comment terminator
                ( $CHARS[$i+1] eq "-" ) &&
                ( $CHARS[$i+2] eq ">" ) ) {
              $i += 2;                                                                          # Adjust character pointer
              $cursor++;                                                                        # Increment Symbol element pointer
              $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},         # Initialise new Symbol
                                                  NodeType      => $NODETYPE{3},
                                                  LineNumber    => $state{LineNo},
                                                  CaseSensitive => $Preprocessor->{CaseSensitive},
                                                  HTMLMode   => $Preprocessor->{HTMLMode},
                                                  ParseText     => $Preprocessor->{ParseText} );
              last CMT;
            } else {
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
            }
          }
          last VECT;
        }
        # Fall Through...
      };


      # Document Type Declaration
      m/[!]/ && do {
        # Note: Cannot handle comments inside DOCTYPE
        if( ( $CHARS[$i-1] =~ m/[<]/ ) && ( join("",@CHARS[$i+1..$i+7]) =~ m/DOCTYPE/i ) ) {     # Check for start of declaration
          my %declare   = ( Nested => 0 );                                                      # Local state hash
          $state{InTag} = 0;                                                                    # Leave tag state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{10} );                           # Flag Symbol as empty tag
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                                     # Flag element as empty
          $i++;                                                                                 # Adjust character pointer
        DECLARE: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                 # Load rest of declaration
            $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                                     # Increment line number
          SWITCH: for( $CHARS[$i] ) {


              # Nested Comment
              m/[!]/ && do {
                if( ( $CHARS[$i-1] eq "<" ) && ( "$CHARS[$i+1]$CHARS[$i+2]" eq "--" ) ) {        # Check for start of comment
                  $state{InTag}                              = 0;                                # Leave tag state
                  $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{8} );                     # Flag Symbol as an XML comment tag
                  $SYMBOLS->[$cursor]->nodeValue( NodeValue => "" );                             # Append character to Symbol
                  $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                              # Flag Symbol as empty tag
                  $i += 3;                                                                       # Adjust character pointer
                CMT: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                              # Load rest of comment
                    $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                              # Increment line number
                    if( ( $CHARS[$i]   eq "-" ) &&                                               # Check for comment terminator
                        ( $CHARS[$i+1] eq "-" ) &&
                        ( $CHARS[$i+2] eq ">" ) ) {
                      $i += 2;                                                                   # Adjust character pointer
                      $cursor++;                                                                 # Increment Symbol element pointer
                      $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},  # Initialise new Symbol
                                                          NodeType      => $NODETYPE{3},
                                                          LineNumber    => $state{LineNo},
                                                          CaseSensitive => $Preprocessor->{CaseSensitive},
                                                          HTMLMode   => $Preprocessor->{HTMLMode},
                                                          ParseText     => $Preprocessor->{ParseText} );
                      last CMT;
                    } else {
                      $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );           # Append character to Symbol
                    }
                  }
                  last SWITCH;
                }
                # Fall Through...
              };


              # Opening Nested Declaration
              m/\[/ && do {
                $declare{Nested} = 1 if( $declare{Nested} == 0 );
                $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                # Append character to Symbol
                last SWITCH;
              };
              # Closing Nested Declaration
              m/\]/ && do {
                $declare{Nested} = 0 if( $declare{Nested} == 1 );
                $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                # Append character to Symbol
                last SWITCH;
              };
              # Nested Declaration Tag
              m/</ && do {
                if( $declare{Nested} == 1 ) {
                  $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );              # Append character to Symbol
                } else {
                  $Preprocessor->_error( Errors  => \%ERRORS,                                   # Generate error message
                                         Module  => $MODULE,
                                         State   => \%state,
                                         Symbol  => $SYMBOLS->[$cursor]->nodeValue(),
                                         Line    => $state{LineNo},
                                         Code    => "0003",
                                         String  => $CHARS[$i],
                                         Context => $SYMBOLS->[$cursor]->nodeType(),
                                         Sample  => $Preprocessor->_sample( Array  => \@CHARS,  #
                                                                            Cursor => $i ) );
                  return( undef );                                                              # Return on error
                }
                last SWITCH;
              };
              # Closing SGML Document Type Declaration
              m/>/ && do {
                $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                # Append character to Symbol
                $SYMBOLS->[$cursor]->subparse( Entities => $Entities ) || return( undef );
                if( $declare{Nested} == 0 ) {
                  $cursor++;                                                                    # Increment Symbol element pointer
                  $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},     # Initialise new Symbol
                                                      NodeType      => $NODETYPE{3},
                                                      LineNumber    => $state{LineNo},
                                                      CaseSensitive => $Preprocessor->{CaseSensitive},
                                                      HTMLMode   => $Preprocessor->{HTMLMode},
                                                      ParseText     => $Preprocessor->{ParseText} );
                  last VECT;
                }
                last SWITCH;
              };
              # Default
              m/./s && do {
                $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                # Append character to Symbol
                last SWITCH;
              };
            }
          }
        }
        # Fall Through...
      };


      # Element Declaration
      m/[!]/ && do {
        if( ( $CHARS[$i-1] =~ m/[<]/ ) && ( join("",@CHARS[$i+1..$i+7]) =~ m/ELEMENT/ ) ) {     # Check for start of declaration
          my %declare   = ( Nested => 0 );                                                      # Local state hash
          $state{InTag} = 0;                                                                    # Leave tag state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $DECLTYPE{1} );                           # Flag Symbol as !ELEMENT declaration
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                                     # Flag element as empty
          $i++;                                                                                 # Adjust character pointer
        ELEMENT: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                 # Load rest of comment
            $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                                     # Increment line number
            if( $CHARS[$i] eq ">" ) {                                                           # Check for tag terminator
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
              my $value         = $SYMBOLS->[$cursor]->nodeValue();
              my $lineo         = $SYMBOLS->[$cursor]->lineNumber();
              $DECLS->[$cursor] = $DECLARATION->new( NodeType   => $DECLTYPE{1},
                                                     NodeValue  => $value,
                                                     LineNumber => $lineo );
              $DECLS->[$cursor]->subparse() || return( undef );
              $i++;
              $cursor++;                                                                        # Increment Symbol element pointer
              $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},         # Initialise new Symbol
                                                  NodeType      => $NODETYPE{3},
                                                  LineNumber    => $state{LineNo},
                                                  CaseSensitive => $Preprocessor->{CaseSensitive},
                                                  HTMLMode   => $Preprocessor->{HTMLMode},
                                                  ParseText     => $Preprocessor->{ParseText} );
              last ELEMENT;
            } else {
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
            }
          }
          last VECT;
        }
        # Fall Through...
      };


      # Entity Declaration
      m/[!]/ && do {
        if( ( $CHARS[$i-1] =~ m/[<]/ ) && ( join("",@CHARS[$i+1..$i+6]) =~ m/ENTITY/ ) ) {     # Check for start of declaration
          my %declare   = ( Nested => 0 );                                                      # Local state hash
          $state{InTag} = 0;                                                                    # Leave tag state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $DECLTYPE{2} );                           # Flag Symbol as !ENTITY declaration
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                                     # Flag element as empty
          $i++;                                                                                 # Adjust character pointer
        ELEMENT: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                 # Load rest of comment
            $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                                     # Increment line number
            if( $CHARS[$i] eq ">" ) {                                                           # Check for tag terminator
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
              my $value         = $SYMBOLS->[$cursor]->nodeValue();
              my $lineo         = $SYMBOLS->[$cursor]->lineNumber();
              $DECLS->[$cursor] = $DECLARATION->new( NodeType   => $DECLTYPE{2},
                                                     NodeValue  => $value,
                                                     LineNumber => $lineo );
              $DECLS->[$cursor]->subparse() || return( undef );
              $i++;
              $cursor++;                                                                        # Increment Symbol element pointer
              $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},         # Initialise new Symbol
                                                  NodeType      => $NODETYPE{3},
                                                  LineNumber    => $state{LineNo},
                                                  CaseSensitive => $Preprocessor->{CaseSensitive},
                                                  HTMLMode   => $Preprocessor->{HTMLMode},
                                                  ParseText     => $Preprocessor->{ParseText} );
              last ELEMENT;
            } else {
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
            }
          }
          last VECT;
        }
        # Fall Through...
      };


      # Attribute Declaration
      m/[!]/ && do {
        if( ( $CHARS[$i-1] =~ m/[<]/ ) && ( join("",@CHARS[$i+1..$i+7]) =~ m/ATTLIST/ ) ) {     # Check for start of declaration
          my %declare   = ( Nested => 0 );                                                      # Local state hash
          $state{InTag} = 0;                                                                    # Leave tag state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $DECLTYPE{3} );                           # Flag Symbol as !ATTLIST declaration
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                                     # Flag element as empty
          $i++;                                                                                 # Adjust character pointer
        ELEMENT: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                 # Load rest of comment
            $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                                     # Increment line number
            if( $CHARS[$i] eq ">" ) {                                                           # Check for tag terminator
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
              my $value         = $SYMBOLS->[$cursor]->nodeValue();
              my $lineo         = $SYMBOLS->[$cursor]->lineNumber();
              $DECLS->[$cursor] = $DECLARATION->new( NodeType   => $DECLTYPE{3},
                                                     NodeValue  => $value,
                                                     LineNumber => $lineo );
              $DECLS->[$cursor]->subparse() || return( undef );
              $i++;
              $cursor++;                                                                        # Increment Symbol element pointer
              $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},         # Initialise new Symbol
                                                  NodeType      => $NODETYPE{3},
                                                  LineNumber    => $state{LineNo},
                                                  CaseSensitive => $Preprocessor->{CaseSensitive},
                                                  HTMLMode   => $Preprocessor->{HTMLMode},
                                                  ParseText     => $Preprocessor->{ParseText} );
              last ELEMENT;
            } else {
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
            }
          }
          last VECT;
        }
        # Fall Through...
      };


      # CDATA Section
      m/[!]/ && do {
        if( ( $CHARS[$i-1] =~ m/[<]/ ) && ( join("",@CHARS[$i+1..$i+7]) =~ m/\[CDATA\[/ ) ) {   # Check for start of character data section
          $state{InTag}     = 0;                                                                # Leave tag state
          $state{InSglQuot} = 0 if( &$inQuotes() );                                             # Leave single quotes state
          $state{InDblQuot} = 0 if( &$inQuotes() );                                             # Leave double quotes state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{4} );                            # Flag Symbol as not a tag
          $SYMBOLS->[$cursor]->nodeValue( NodeValue => "" );                                    # Re-initialise Symbol content
          $i += 8;                                                                              # Adjust character pointer
        CDATA: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                   # Load rest of CDATA
            if( $CHARS[$i] eq "]" ) {                                                           # Check for CDATA terminator
              if( join( "", @CHARS[$i+1..$i+2] ) =~ m/\]>/ ) {                                  # Look for CDATA terminator
                $i += 2;                                                                        # Adjust character pointer
                last CDATA;                                                                     # Break inner loop
              }
            }
            $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                    # Append character to Symbol
          }
          $cursor++;                                                                            # Increment Symbol element pointer
          $SYMBOLS->[$cursor] = $SYMBOL->new( Debug         => $Preprocessor->{Debug},             # Initialise new Symbol
                                              NodeType      => $NODETYPE{3},
                                              LineNumber    => $state{LineNo},
                                              CaseSensitive => $Preprocessor->{CaseSensitive},
                                              HTMLMode   => $Preprocessor->{HTMLMode},
                                              ParseText     => $Preprocessor->{ParseText} );
          last VECT;
        }
        # Fall Through...
      };


      # Catch Falling Exclamation Mark
      m/[!]/ && do {
        $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{3} ) if( ! $state{InTag} );        # Set Symbol description
        $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                               # Append character to Symbol
        last VECT;
      };


      # XML Processing Instruction
      m/[?]/ && do {
        if( &$inQuotes() ) {                                                                    # Am I inside quotes?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT;
        }
        if( $CHARS[$i-1] =~ m/[<]/ ) {
          $state{InTag} = 0;                                                                    # Leave tag state
          $SYMBOLS->[$cursor]->nodeType( NodeType => $NODETYPE{7} );                            # Flag Symbol as empty tag
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          $SYMBOLS->[$cursor]->nodeEmpty( NodeEmpty => 1 );                                     # Flag element as empty
          $i++;                                                                                 # Adjust character pointer
        PI: for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                      # Load rest of directive
            $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                                     # Increment line number
            $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                    # Append character to Symbol
            if( ( $CHARS[$i] =~ m/[?]/ ) && ( $CHARS[$i+1] =~ m/[>]/ ) ) {                      # XML Strict : Check for Processing Instruction terminator
              $i++;                                                                             # Adjust character pointer
              $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                  # Append character to Symbol
              last PI;
            } elsif( $CHARS[$i] =~ m/[>]/ ) {                                                   # SGML Sloppy : Check for terminating angle bracket
              if( $Preprocessor->{Strict} eq "yes" ) {                                              # Operating under Strict XML
                $Preprocessor->_error( Errors  => \%ERRORS,                                     # Generate error message
                                       Module  => $MODULE,
                                       State   => \%state,
                                       Symbol  => $SYMBOLS->[$cursor]->nodeValue(),
                                       Line    => $state{LineNo},
                                       Code    => "0009",
                                       String  => "?",
                                       Context => $SYMBOLS->[$cursor]->nodeType(),
                                       Sample  => $Preprocessor->_sample( Array  => \@CHARS,
                                                                          Cursor => $i ) );
              } else {                                                                          # SGML Sloppy
                last PI;
              }
            }
          }
        }
        # Fall Through...
      };


      # White Space
      m/[\x20\x09\x0D\x0A]/ && do {                                                             # Space, tab, newline and carriage return
        my $lastchar = "";
        if( $state{InTag} ) {                                                                   # Am I inside a tag?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT;
        }
        if( $SYMBOLS->[$cursor]->nodeValue() ) {
          ( $lastchar ) = ( $SYMBOLS->[$cursor]->nodeValue() =~ m/(.)$/gs );                    # Fetch the previous character
        }
        last VECT if( ( $lastchar =~ m/^ $/s ) || ( $lastchar =~ m/^$/s ) );                    # Was the previous character a space or null ?
        $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => " " );                               # Append space character to Symbol
        last VECT;
      };


      # Attribute Value
      m/[=]/ && do {
        if( $state{InTag} ) {                                                                   # Am I inside a tag ?
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                             # Append character to Symbol
          last VECT if( &$inQuotes() );                                                         # Am I inside quotes ?
        CHECK: for( $CHARS[$i+1] ) {
            m/[\"\']/ && do {                                                                   # Beginning of attribute value
              $Preprocessor->boolean( Bool => \$state{InAttrVal} );                             # Switch attribute state
              last CHECK;
            };


            m/[^\"\']/ && ( $Preprocessor->{HTMLMode} eq "yes" ) && do {                     # Accept quoteless HTML attribute values
              $i++;
              for( $i = $i ; $i <= ( @CHARS - 1 ) ; $i++ ) {                                    # Load rest of comment
                $state{LineNo}++ if( $CHARS[$i] =~ m/[\x0A]/ );                                 # Increment line number
                if( $CHARS[$i+1] =~ m/[ \t\/>]/ ) {
                  $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );              # Append character to Symbol
                  $state{InAttrVal} = 0;
                  last VECT;
                }
                $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CHARS[$i] );                # Append character to Symbol
              }
              last VECT;
            };


            m/[^\"\']/ && do {                                                                  # Default
              $Preprocessor->_error( Errors  => \%ERRORS,                                       # Generate error message
                                     Module  => $MODULE,
                                     State   => \%state,
                                     Symbol  => $SYMBOLS->[$cursor]->nodeValue(),
                                     Line    => $state{LineNo},
                                     Code    => "0004",
                                     String  => $CC,
                                     Context => $SYMBOLS->[$cursor]->nodeType(),
                                     Sample  => $Preprocessor->_sample( Array  => \@CHARS,
                                                                        Cursor => $i ) );
              return( undef );
            };
          }
          last VECT;
        }
        # Fall Through...
      };


      # Single Quotes
      m/[\']/ && do {
        if( $state{InTag} != 0 ) {                                                              # No special action if outside of a tag
          if( ( $state{InDblQuot} == 1 ) && ( $state{InAttrVal} == 1 ) ) {                      # Entering attribute value
            $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                           # Append character to Symbol
            last VECT;
          }
          if( ( $state{InSglQuot} == 0 ) && ( $state{InAttrVal} == 1 ) ) {                      # Entering attribute value
            $Preprocessor->boolean( Bool => \$state{InSglQuot} );                               # Switch double quotes state
          } elsif( ( $state{InSglQuot} == 1 ) && ( $state{InAttrVal} == 1 ) ) {                 # Leaving attribute value
            $Preprocessor->boolean( Bool => \$state{InSglQuot} );                               # Switch double quotes state
            $Preprocessor->boolean( Bool => \$state{InAttrVal} );                               # Switch double quotes state
          } else {
            ;
          }
        }
        # Fall Through...
      };


      # Double Quotes
      m/[\"]/ && do {
        if( $state{InTag} != 0 ) {                                                              # No special action if outside of a tag
          if( ( $state{InSglQuot} == 1 ) && ( $state{InAttrVal} == 1 ) ) {                      # Entering attribute value
            $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                           # Append character to Symbol
            last VECT;
          }
          if( ( $state{InDblQuot} == 0 ) && ( $state{InAttrVal} == 1 ) ) {                      # Entering attribute value
            $Preprocessor->boolean( Bool => \$state{InDblQuot} );                               # Switch double quotes state
          } elsif( ( $state{InDblQuot} == 1 ) && ( $state{InAttrVal} == 1 ) ) {                 # Leaving attribute value
            $Preprocessor->boolean( Bool => \$state{InDblQuot} );                               # Switch double quotes state
            $Preprocessor->boolean( Bool => \$state{InAttrVal} );                               # Switch double quotes state
          } else {
            ;
          }
        }
        # Fall Through...
      };


      # Possible Attribute Name
      m/./ && ( $Preprocessor->{HTMLMode} eq "yes" ) && do {
        if( ( $CHARS[$i+1] =~ m/[ \t>]/ ) &&
            ( $state{InDblQuot} == 0 ) &&
            ( $state{InAttrVal} == 1 ) ) {
          $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                               # Append character to Symbol
          last VECT;
        }
      };


      # Default
      m/./ && do {
        $SYMBOLS->[$cursor]->nodeValueAppend( NodeValue => $CC );                               # Append character to Symbol
        last VECT;
      };


    }
  }
  $Preprocessor->_state( State => \%state )      || return( undef );                            # Verify the state machine
  $Preprocessor->_compactDecl( Array => $DECLS ) || return( undef );                            # Compact the Declarations table
  $Preprocessor->_compactSyms()                  || return( undef );                            # Compact the Symbol table
  $Preprocessor->_downcase() if( $Preprocessor->{CaseSensitive} eq "no" );
  return( undef ) if( $Preprocessor->_orphans() );                                              # Check for orphaned tags
  return( undef ) if( $Preprocessor->_balance() );                                              # Check for unbalanced tags
  $i = scalar @CHARS + 1;                                                                       # This is for the Watchman thread
  undef $tied;                                                                                  # Destroy tied object
  untie @CHARS;                                                                                 # Disassociate array from tied class
  if( $Preprocessor->{Debug} ) {
    print( STDERR "\t\tSYMBOL TABLE\n" );
    foreach my $sym ( @{$Preprocessor->{Symbols}} ) {
      print( STDERR "\t" x 3 . $sym->nodeValue() . "\n" );
    }
  }
  print( STDERR "\tPreprocessing Complete\n" ) if( $Preprocessor->{Debug} );                           # DEBUG
  return(1);
}


sub _state {
  # This private method inspects the state machine for inconsistencies.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  #    hash    {
  #              State => \%state
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Preprocessor = shift;                                                          # Get Preprocessor
  my %args         = @_;                                                             # Get arguments
  my $State        = $args{State};                                                   # Get state hash reference
  if( $Preprocessor->{Debug} ) {
    print( STDERR "\t\tVerifying State Machine\n" );
    foreach my $key ( keys %{$State} ) {
      print( STDERR "\t" x 3 . "$key => $State->{$key}\n" ) if( defined $State->{$key} );
    }
  }
  if( $State->{InTag} ) {                                                            # Out of data error
    $Preprocessor->_error( Errors  => \%ERRORS,                                      # Generate error message
                           Module  => $MODULE,
                           State   => $State,
                           Symbol  => $Preprocessor->{Symbols}->[-1]->nodeValue(),
                           Line    => $State->{LineNo},
                           Code    => "0008",
                           String  => $Preprocessor->{Symbols}->[-1]->nodeValue(),
                           Context => $Preprocessor->{Symbols}->[-1]->nodeType() );
    return( undef );
  }
  return(1);
}


sub _compactDecl {
  # This private method compacts the Declarations table.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  #    hash    {
  #              Array => \@DECLS
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Preprocessor = shift;                                                     # Get Preprocessor
  my %args         = @_;                                                        # Get arguments
  my $Declarations = $args{Array};
  my $compact      = [];                                                        # New compact elements array
  print( STDERR "\t\tCompacting Declarations Table\n" ) if( $Preprocessor->{Debug} );  # DEBUG
 LOAD: foreach my $Symbol ( @{$Declarations} ) {                                # Iterate over Declarations
    next LOAD if( ! defined $Symbol );
    my $Name = $Symbol->nodeName();
    $Preprocessor->{Declarations}->{$Name} = $Symbol;
  }
  return(1);
}


sub _compactSyms {
  # This private method compacts the Symbol table.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Preprocessor = shift;                                               # Get Preprocessor
  my %args         = @_;                                                  # Get arguments
  my $Entities     = $Preprocessor->{Entities};                           # Get Entities table reference
  my $compact      = [];                                                  # New compact elements array
  print( STDERR "\t\tCompacting Symbol Table\n" ) if( $Preprocessor->{Debug} );  # DEBUG
 LOAD: foreach my $i ( @{$Preprocessor->{Symbols}} ) {                    # Iterate over elements
    my $value = $i->nodeValue();                                          # Get entity content
    next LOAD if( ! defined $value );
    $value    =~ s/^[ \t\x0D\x0A]+$//gs;                                  # Strip white space only elements
    $value    =~ s/^[ \t\x0D\x0A]*(.+)[ \t\x0D\x0A]*$/$1/gs;              # Strip leading and trailing white space
    if( length( $value ) >= 1 ) {                                         # Check for valid entity
      if( $i->nodeType eq "TEXT_NODE" ) {                                 # Sub-parse text nodes
        if( ( $Preprocessor->{Debug} ) && ( defined $Entities ) ) {       # DEBUG
          print( STDERR "\t\t\t_compact $Entities\n" );
        }
        $i->subparse( Entities => $Entities ) || return( undef );         # Sub-parse text node, passing in Entities table
      }
      push( @{$compact}, $i );
    }
  }
  undef @{$Preprocessor->{Symbols}};
  $Preprocessor->{Symbols} = $compact;
  return(1);
}


sub _downcase {
  # This private method downcases all Node names and namespaces in case insensitive mode.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Preprocessor = shift;                                                     # Get Preprocessor
  my %args         = @_;                                                        # Get arguments
  print( STDERR "\t\tDowncasing Node Names\n" ) if( $Preprocessor->{Debug} );          # DEBUG
 SYMBOLS: foreach my $Symbol ( @{$Preprocessor->{Symbols}} ) {                  # Search Symbol table
    next SYMBOLS if( $Symbol->nodeType() !~ m/ELEMENT_NODE/ );
    $Symbol->nodeNamespace( NodeNamespace => lc( $Symbol->nodeNamespace() ) );  #
    $Symbol->nodeName( NodeName => lc( $Symbol->nodeName() ) );
  }
  return(1);
}


sub _orphans {
  # This private method scans the Symbol table for orphaned closing tags.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  #    hash    {
  #              Symbols => \@symbols
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Preprocessor = shift;                                                          # Get Preprocessor
  my %args         = @_;                                                             # Get arguments
  my %opening      = ();                                                             # Hash keeps tally for each tag found
  my %closing      = ();
  my %openingSym   = ();
  my %closingSym   = ();
  my $flag         = 0;                                                              # Raised flag indicates error
  return( $flag ) if( $Preprocessor->{Orphans} == 1 );
  print( STDERR "\t\tSearching for Orphans\n" ) if( $Preprocessor->{Debug} );               # DEBUG
 SYMBOLS: foreach my $Symbol ( @{$Preprocessor->{Symbols}} ) {                       # Search Symbol table
    next SYMBOLS if( $Symbol->nodeType() =~ m/(TEXT_NODE|
                                               CDATA_SECTION_NODE|
                                               PROCESSING_INSTRUCTION_NODE|
                                               COMMENT_NODE|
                                               DOCUMENT_TYPE_NODE)/x );              # Skip non-Element tags
    my $namespace = $Symbol->nodeNamespace();                                        # Get Node Namespace
    my $tagname   = $Symbol->nodeName();                                             # Get Node Name
    my $combined  = $tagname;
    $combined     = "$namespace:$tagname" if( $namespace );                          # Prefix namespace
    next SYMBOLS if( $tagname =~ m/^$/ );                                            # Skip nameless Node Type
    if( ! $Symbol->nodeClosing() ) {
      if( ! $Symbol->nodeEmpty() ) {                                                 # Increment opening tag counter
        $opening{$combined} += 1;
        $closing{$combined} -= 1;                                                    # Closing element found
        if( ! exists( $openingSym{$combined} ) ) {
          $openingSym{$combined} = [];
        }
        push( @{$openingSym{$combined}}, $Symbol );
        pop( @{$closingSym{$combined}} );
      }
    } else {
      $closing{$combined} += 1;                                                      # Closing element found
      if( ! exists( $closingSym{$combined} ) ) {
        $closingSym{$combined} = [];
      }
      push( @{$closingSym{$combined}}, $Symbol );
    }
  }
  foreach my $tag ( keys %closing ) {                                                # Search for unbalanced tags
    if( $closing{$tag} > 0 ) {                                                       # Is the Tally non-zero?
      my $idx = $closing{$tag} - 1;
      $idx    = 0 if( $idx < 0 );
      if( defined $closingSym{$tag}->[$idx] ) {
        $Preprocessor->_error( Errors  => \%ERRORS,                                  # Generate error message
                               Module  => $MODULE,
                               Line    => $closingSym{$tag}->[$idx]->lineNumber(),
                               Code    => "0005",
                               String  => $tag,
                               Context => $closingSym{$tag}->[$idx]->nodeType(),
                               Sample  => $closingSym{$tag}->[$idx]->nodeValue() );  #
      } else {
        $Preprocessor->_error( Errors => \%ERRORS,                                   # Generate error message
                               Module => $MODULE,
                               Code   => "0005",
                               String => $tag,
                               Context => $closingSym{$tag}->[$idx]->nodeType() );
      }
      $flag++;                                                                       # Raise error flag
    }
  }
  return( $flag );                                                                   # Return flag
}


sub _balance {
  # This private method scans the Symbol table for unbalanced tags.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Preprocessor = shift;                                                       # Get Preprocessor
  my %args         = @_;                                                          # Get arguments
  my %tally        = ();                                                          # Hash keeps tally for each tag found
  my %symlist      = ();
  my $flag         = 0;                                                           # Raised flag indicates error
  print( STDERR "\t\tBalancing Tags\n" ) if( $Preprocessor->{Debug} );                   # DEBUG
 SYMBOLS: foreach my $Symbol ( @{$Preprocessor->{Symbols}} ) {                    # Search Symbol table
    next SYMBOLS if( $Symbol->nodeType() =~ m/(TEXT_NODE|
                                               CDATA_SECTION_NODE|
                                               PROCESSING_INSTRUCTION_NODE|
                                               COMMENT_NODE|
                                               DOCUMENT_TYPE_NODE)/x );           # Skip non-Element tags
    my $namespace = $Symbol->nodeNamespace();                                     # Get Node Namespace
    my $tagname   = $Symbol->nodeName();                                          # Get Node Name
    my $combined  = $tagname;
    $combined     = "$namespace:$tagname" if( $namespace );                       # Prefix namespace
    next SYMBOLS if( $tagname =~ m/^$/ );                                         # Skip nameless Node Type
    if( ! $Symbol->nodeClosing() ) {
      $tally{$combined} += 1 if( ! $Symbol->nodeEmpty() );                        # Opening element found
      if( ! exists( $symlist{$combined} ) ) {
        $symlist{$combined} = [];
      }
      push( @{$symlist{$combined}}, $Symbol );
    } else {
      $tally{$combined} -= 1;                                                     # Closing element found
    }
  }
  foreach my $tag ( keys %tally ) {                                               # Search for unbalanced tags
    if( $tally{$tag} ) {                                                          # Is the Tally non-zero?
      my $idx = $tally{$tag} - 1;
      $idx    = 0 if( $idx < 0 );
      if( defined $symlist{$tag}->[$idx] ) {
        $Preprocessor->_error( Errors  => \%ERRORS,                               # Generate error message
                               Module  => $MODULE,
                               Line    => $symlist{$tag}->[$idx]->lineNumber(),
                               Code    => "0006",
                               String  => $tag,
                               Context => $symlist{$tag}->[$idx]->nodeType(),
                               Sample  => $symlist{$tag}->[$idx]->nodeValue() );  #
      } else {
        $Preprocessor->_error( Errors  => \%ERRORS,                               # Generate error message
                               Module  => $MODULE,
                               Code    => "0007",
                               #Context => $symlist{$tag}->[$idx]->nodeType() || "",
                               String  => $tag );
      }
      $flag++;                                                                    # Raise error flag
    }
  }
  return( $flag );                                                                # Return flag
}


sub declarations {
  # This method returns the Declarations table as an array reference.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  # Result Returned:
  #    array reference
  # Example:
  #    method call
  my $Preprocessor = shift;                 # Get Preprocessor
  return( $Preprocessor->{Declarations} );  # Return Declarations table array reference
}


sub symbols {
  # This method returns the Symbol table as an array reference.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  # Result Returned:
  #    array reference
  # Example:
  #    method call
  my $Preprocessor = shift;                     # Get Preprocessor
  my $Symbols      = $Preprocessor->{Symbols};  # Get Symbol table
  return( $Symbols );                           # Return Symbol table array reference
}


sub entities {
  # This method returns the character entities from all of the Symbols.
  # Calls:
  #    none
  # Parameters Required:
  #    Preprocessor
  # Result Returned:
  #    array reference
  # Example:
  #    method call
  my $Preprocessor = shift;                             # Get Preprocessor
  my %Entities     = ();                                # Hash holds character entity translation table
  foreach my $Symbol ( @{$Preprocessor->{Symbols}} ) {  # Iterate over Symbol table
    my $Table = $Symbol->entities();
    foreach my $key ( keys %{$Table} ) {
      $Entities{$key} = $Table->{$key};
    }
  }
  return( \%Entities );
}


sub DESTROY {
  my $Preprocessor = shift;
  $Preprocessor->{Declarations} = {};
  $Preprocessor->{Symbols}      = [];
  return(1);
}


__DATA__
0001  Missing right angle-bracket in __ tag
0002  Illegal character __ in !! context
0003  Illegal character __ in SGML Declaration
0004  Expecting opening double quote near __
0005  Orphaned closing __ tag
0006  Expecting closing tag for element __
0007  Possible case-mismatch between opening and closing tags for __
0008  Expecting more data in !! context
0009  Expecting __ in !! context
