#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser::Preprocessor::Declaration.pm v00.00.01b 12042000
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
#                This class manages Declaration objects.
#
#
#   Methods:
#       initialise       -  This method is the object initialiser for this class
#       nodeType         -  This method gets/sets the Symbol NodeType property
#       nodeValue        -  This method gets/sets the Symbol NodeValue property
#       nodeValueAppend  -  This method appends to the NodeValue property
#       nodeName         -  This private method returns the name of a tag
#       nodeAttributes   -  This method gets the Symbol attributes
#       nodeDoctype      -  This method gets the Doctype fields
#       lineNumber       -  This method gets/sets the Symbol LineNumber property
#       subparse         -  This method sub-parses the Symbol's contents


package NetSoup::XML::Parser::Preprocessor::Declaration;
use strict;
use NetSoup::XML::Parser::Errors;
@NetSoup::XML::Parser::Preprocessor::Declaration::ISA = qw( NetSoup::XML::Parser::Errors );
my $MODULE   = "Declaration";
my %ERRORS   = ();
my %DECLTYPE = ( 1 => "ELEMENT_DECL",
                 2 => "ENTITY_DECL",
                 3 => "ATTLIST_DECL" );
while( <NetSoup::XML::Parser::Preprocessor::Declaration::DATA> ) {
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
  #    Declaration
  #    hash    {
  #              Debug       => 0 | 1
  #              NodeType    => DECLTYPE
  #              NodeValue   => $NodeValue
  #              NodeEmpty   => 0 | 1
  #              NodeClosing => 0 | 1
  #              LineNumber  => $LineNumber
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Declaration = NetSoup::XML::Parser::Declaration->initialise();
  my $Declaration                       = shift;                     # Get object
  my %args                              = @_;                        # Get arguments
  $Declaration->{Debug}                 = $args{Debug}       || 0;   # Get debug flag
  $Declaration->{DTD}->{NodeName}       = "";                        # NodeName
  $Declaration->{DTD}->{NodeType}       = $args{NodeType}    || "";  # NodeType
  $Declaration->{DTD}->{NodeValue}      = $args{NodeValue}   || "";  # NodeValue
  $Declaration->{Regex}                 = "";                        # Rule in regular expression format
  $Declaration->{Attlist}               = {};                        # Attlist structure
  $Declaration->{NetSoup}->{LineNumber} = $args{LineNumber}  || 0;   # NetSoup Specific : Line number of tag
  $Declaration->clearErr();                                          # Clear error messages
  return( $Declaration );
}


sub nodeType {
  # This method gets/sets the Declaration NodeType property.
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
  #    my $nodeType = $Declaration->nodeType();
  my $Declaration = shift;                              # Get object
  my %args        = @_;                                 # Get arguments
  if( exists $args{NodeType} ) {                        # Check for argument
    $Declaration->{DTD}->{NodeType} = $args{NodeType};  # Set property
  }
  return( $Declaration->{DTD}->{NodeType} );            # Return property
}


sub nodeValue {
  # This method gets/sets the Declaration NodeValue property.
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
  #    my $nodeValue = $Declaration->nodeValue();
  my $Declaration = shift;                                # Get object
  my %args        = @_;                                   # Get arguments
  if( exists $args{NodeValue} ) {                         # Check for argument
    $Declaration->{DTD}->{NodeValue} = $args{NodeValue};  # Set property
  }
  return( $Declaration->{DTD}->{NodeValue} );             # Return property
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
  #    my $nodeValue = $Declaration->nodeValueAppend( NodeValue => $nodeValue );
  my $Declaration                  = shift;                                         # Get object
  my %args                         = @_;                                            # Get arguments
  $Declaration->{DTD}->{NodeValue} = $Declaration->nodeValue() . $args{NodeValue};  # Set property
  return( $Declaration->{DTD}->{NodeValue} );                                       # Return property
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
  my $Declaration = shift;                              # Get object
  my %args        = @_;                                 # Get arguments
  if( exists $args{NodeName} ) {                        # Check for argument
    $Declaration->{DTD}->{NodeName} = $args{NodeName};  # Set property
  }
  return( $Declaration->{DTD}->{NodeName} );            # Return NodeName
}


sub nodeRegex {
  # This private method returns the regular expression.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Declaration = shift;                 # Get object
  my %args        = @_;                    # Get arguments
  if( exists $args{NodeRegex} ) {          # Check for argument
    $Declaration->{Regex} = $args{Regex};  # Set property
  }
  return( $Declaration->{Regex} );         # Return Regex
}


sub lineNumber {
  # This method gets/sets the Declaration LineNumber property.
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
  #    my $lineNumber = $Declaration->lineNumber();
  my $Declaration = shift;                                      # Get object
  my %args   = @_;                                              # Get arguments
  if( exists $args{LineNumber} ) {                              # Check for argument
    $Declaration->{NetSoup}->{LineNumber} = $args{LineNumber};  # Set property
  }
  return( $Declaration->{NetSoup}->{LineNumber} );              # Return property
}


sub subparse {
  # This method sub-parses the Declaration's contents.
  # Calls:
  #    none
  # Parameters Required:
  #    Declaration
  # Result Returned:
  #    boolean
  # Example:
  #    $Declaration->subparse();
  my $Declaration = shift;                                                    # Get Declaration object
  my %args        = @_;                                                       # Get arguments
 DECL: for( $Declaration->{DTD}->{NodeType} ) {


    m/ELEMENT_DECL/ && do {
      my @chars = split( //, $Declaration->{DTD}->{NodeValue} );
      my $i     = 0;
      if( ( $chars[0] =~ m/[^<]/ ) || ( $chars[-1] =~ m/[^>]/ ) ) {           # Check for missing <> characters
        $Declaration->_error( Errors => \%ERRORS,                             # Generate error message
                              Module => $MODULE,
                              Line   => $Declaration->lineNumber(),
                              Code   => "0001",
                              String => "",
                              Sample => $Declaration->nodeValue() );
        return( undef );
      }
    PREAMBLE: for( $i = 0 ; $i <= ( @chars - 1 ) ; $i++ ) {                   # Strip !ELEMENT
        if( $chars[$i] =~ m/[ \t\x0A\x0D]/gis ) {
          $i++;
          last PREAMBLE;
        }
      }
      my $Regex = $Declaration->_spElement( Chars => \@chars,
                                            Index => $i) || return( undef );  #
      $Declaration->{Regex} = $Regex;                                          # Rule in regular expression format
      last DECL;
    };


    m/ENTITY_DECL/ && do {
      print( STDERR $Declaration->nodeValue() . "\n" );                              # DEBUG
      $Declaration->_spEntity() || return( undef );
      last DECL;
    };


    m/ATTLIST_DECL/ && do {
      print( STDERR $Declaration->nodeValue() . "\n" );                              # DEBUG
      my @chars = split( //, $Declaration->{DTD}->{NodeValue} );
      my $i     = 0;
      if( ( $chars[0] =~ m/[^<]/ ) || ( $chars[-1] =~ m/[^>]/ ) ) {           # Check for missing <> characters
        $Declaration->_error( Errors => \%ERRORS,                             # Generate error message
                              Module => $MODULE,
                              Line   => $Declaration->lineNumber(),
                              Code   => "0001",
                              String => "",
                              Sample => $Declaration->nodeValue() );
        return( undef );
      }
    PREAMBLE: for( $i = 0 ; $i <= ( @chars - 1 ) ; $i++ ) {                     # Strip !ATTLIST
        if( $chars[$i] =~ m/[ \t\x0A\x0D]/gis ) {
          $i++;
          last PREAMBLE;
        }
      }
      my $Attlist = $Declaration->_spAttlist( Chars => \@chars,
                                              Index => $i) || return( undef );  #
      my $Target  = $Attlist->{Target};
      $Declaration->{Attlist}->{Target} = { Name    => $Attlist->{Name},        # Insert Attlist structure into object
                                            Regex   => $Attlist->{Regex},
                                            Default => $Attlist->{Default} };
      last DECL;
    };
    
    
    m// && do {
      print( STDERR qq(NODETYPE\t"$_" not supported\n) );                              # DEBUG
      last DECL;
    };


  }
  return(1);
}


sub _spElement {
  # This private method parses the element declaration.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Chars => \@Chars
  #              Index => $i
  #            }
  # Result Returned:
  #    RuleRegex
  # Example:
  #    my $Regex = $Declaration->_spElement( Chars => \@Chars, Index => 0 );
  my $Declaration = shift;
  my %args        = @_;
  my $Chars       = $args{Chars};
  my $i           = $args{Index} || 0;
  my %State       = ( Name => 1 );
  my $Name        = "";
  my $Regex       = "^";
 CHARS: for( $i = $i ; $i <= ( @{$Chars} - 1 ) ; $i++ ) {
  SWITCH: for( $Chars->[$i] ) {
      # Whitespace
      m/[ \t\x0A\x0D>]/gs && do {
        last SWITCH;
      };
      # Word Character
      m/[\#\x2D\w\d_:]/gs && do {
        if( $State{Name} ) {
          $Name .= $Chars->[$i];
          if( $Chars->[$i+1] =~ m/[ \t\x0A\x0D]/ ) {
            $Declaration->{DTD}->{NodeName} = $Name;
            $State{Name} = 0;
            $i++;
          }
        } else {
          if( $Chars->[$i..$i+2] =~ m/ANY/ ) {
            $Regex .= '^.+';
            last CHARS;
          }
          $Regex .= $Chars->[$i];
        }
        last SWITCH;
      };
      # Or Character
      m/[|]/gs && do {
        $Regex .= $Chars->[$i];
        last SWITCH;
      };
      # Recurrence Character
      m/[?+*]/gs && do {
        if( $Regex =~ m/[\#\x2D\w\d_:]$/ ) {
          $Regex =~ s/([\#\x2D\w\d_:]+)$/($1)/;
        }
        $Regex .= $Chars->[$i];
        last SWITCH;
      };
      # Comma
      m/[,]/gs && do {
        $Regex .= " ";
        last SWITCH;
      };
      # Enter Nested Rule
      m/[\(]/gs && do {
        $Regex .= $Chars->[$i];
        last SWITCH;
      };
      # Leave Nested Rule
      m/[\)]/gs && do {
        $Regex .= $Chars->[$i];
        last SWITCH;
      };
      # Error
      m/./gs && do {
        print( STDERR qq(ERROR\t"$Chars->[$i]"\t) . ord($Chars->[$i]) . "\n" );
        last SWITCH;
      };
    }
  }
  $Regex .= "\$";
  return( $Regex );
}


sub _spEntity {
  # This private method parses the entity declaration.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    hash reference
  # Example:
  #    my %attributes = $Declaration->_spElement();
  my $Declaration = shift;
  my %args        = @_;
  return(1);
}


sub _spAttlist {
  # This private method parses the attlist declaration.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    hash reference
  # Example:
  #    my $Attlist = $Declaration->_spElement();
  my $Declaration = shift;
  my %args        = @_;
  my $Chars       = $args{Chars};
  my $i           = $args{Index} || 0;
  my %State       = ( Target => 1,
                      Name   => 0 );
  my $Target      = "";
  my $Attlist     = { Name    => "",
                      Regex   => "^",
                      Default => "" };
 CHARS: for( $i = $i ; $i <= ( @{$Chars} - 1 ) ; $i++ ) {
  SWITCH: for( $Chars->[$i] ) {
      # Whitespace
      m/[ \t\x0A\x0D>]/gs && do {
        last SWITCH;
      };
      # Word Character
      m/[\#\x2D\w\d_:]/gs && do {
        if( $State{Target} ) {
          $Target .= $Chars->[$i];
          if( $Chars->[$i+1] =~ m/[ \t\x0A\x0D]/ ) {
            $Declaration->{DTD}->{NodeName} = $Target;
            $State{Target} = 0;
            $State{Name}   = 1;
            $i++;
          }
        } elsif( $State{Name} ) {
          $Attlist->{Name} .= $Chars->[$i];
          if( $Chars->[$i+1] =~ m/[ \t\x0A\x0D]/ ) {
            $State{Name} = 0;
            $i++;
          }
        } else {
          $Attlist->{Regex} .= $Chars->[$i];
        }
        last SWITCH;
      };
      # Or Character
      m/[|]/gs && do {
        $Attlist->{Regex} .= $Chars->[$i];
        last SWITCH;
      };
      # Recurrence Character
      m/[?+*]/gs && do {
        if( $Attlist->{Regex} =~ m/[\#\x2D\w\d_:]$/ ) {
          $Attlist->{Regex} =~ s/([\#\x2D\w\d_:]+)$/($1)/;
        }
        $Attlist->{Regex} .= $Chars->[$i];
        last SWITCH;
      };
      # Comma
      m/[,]/gs && do {
        $Attlist->{Regex} .= " ";
        last SWITCH;
      };
      # Enter Nested Rule
      m/[\(]/gs && do {
        $Attlist->{Regex} .= $Chars->[$i];
        last SWITCH;
      };
      # Leave Nested Rule
      m/[\)]/gs && do {
        $Attlist->{Regex} .= $Chars->[$i];
        last SWITCH;
      };
      # Error
      m/./gs && do {
        print( STDERR qq(ERROR\t"$Chars->[$i]"\t) . ord($Chars->[$i]) . "\n" );
        last SWITCH;
      };
    }
  }
  $Attlist->{Regex} .= "\$";
  return( $Attlist );
}


sub DESTROY {
  my $Declaration = shift;
  #warn( "DESTROYING $Declaration\n" ) if( $Declaration->{Debug} );
  return(1);
}


__DATA__
0001  Expecting angle-bracket in declaration __
