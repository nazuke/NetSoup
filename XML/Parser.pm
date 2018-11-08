#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser.pm v00.00.01g 12042000
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
#                This class provides a front-end to the XML
#                Preprocessor and Compiler classes.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       parse       -  This method parses a chunk of XML text into a DOM2 parse tree
#       flag        -  This method returns a specified flag value


package NetSoup::XML::Parser;
use strict;
use NetSoup::Core;
use NetSoup::XML::Parser::Errors;
use NetSoup::XML::Parser::Preprocessor;
use NetSoup::XML::Parser::Compiler;
@NetSoup::XML::Parser::ISA = qw( NetSoup::Core
                                 NetSoup::XML::Parser::Errors );
my $MODULE       = "Parser";
my $PREPROCESSOR = "NetSoup::XML::Parser::Preprocessor";
my $COMPILER     = "NetSoup::XML::Parser::Compiler";
1;


sub BEGIN {}


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash    {
  #              Debug     =>    0 | 1
  #              Strict    => "no" | "yes"
  #              Orphans   =>    0 | 1
  #              Entities  => \%Entities
  #              ParseText => "no" | "yes"
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Parser->initialise();
  my $Parser           = shift;                      # Get Parser object
  my %args             = @_;                         # Get arguments
  $Parser->{Debug}     = $args{Debug}     || 0;      # Get debugging flag
  $Parser->{Strict}    = $args{Strict}    || "yes";  # Get Strict XML flag
  $Parser->{Orphans}   = $args{Orphans}   || 0;      # Get orphan checking switch
  $Parser->{Entities}  = $args{Entities}  || ();     # Get Entities table reference
  $Parser->{Empty}     = $args{Empty}     || [];     # Get Empty element list reference
  $Parser->{ParseText} = $args{ParseText} || "yes";  # Get ParseText flag
  $Parser->{Document}  = undef;
  $Parser->{Errors}    = {};
  $Parser->{Flags}     = { Preprocessed => 0,        # Flag XML has been preprocessed
                           Compiled     => 0,        # Flag XML has been compiled
                           Ready        => 0,        # Flag XML is ready for traversal
                           Error        => 0 };      # Flag an error hash occurred
  return( $Parser );
}


sub parse {
  # This method parses a chunk of XML text into a DOM2 parse tree.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash    {
  #              XML        => \$xml
  #              Whitespace => "preserve" || "compact"
  #            }
  # Result Returned:
  #    $Parser || undef
  # Example:
  #    method call
  my $Parser       = shift;                                                        # Get Parser
  my %args         = @_;                                                           # Get arguments
  my $XML          = $args{XML}        || undef;                                   # Get XML data reference
  my $whitespace   = $args{Whitespace} || "compact";                               # Get white space flag
  $Parser->clearErr();                                                             # Clear accumulated error messages
  print( STDERR "Beginning XML Parsing\n" ) if( $Parser->{Debug} );                # DEBUG
  my $PP = $PREPROCESSOR->new( Debug     => $Parser->{Debug},                      # Get new Preprocessor object
                               Strict    => $Parser->{Strict},
                               Orphans   => $Parser->{Orphans},
                               Entities  => $Parser->{Entities},
                               Empty     => $Parser->{Empty},
                               ParseText => $Parser->{ParseText} );
  my $preprocessed = $PP->preprocessor( XML        => $XML,                        # Preprocess XML into Symbol table
                                        Whitespace => $whitespace );
  if( ( defined $preprocessed ) && ( $preprocessed == 1 ) ) {
    $Parser->{Flags}->{Preprocessed} = 1;                                          # Flag Parser as preprocessed
    print( STDERR "\tCompiling Document Object Model\n" ) if( $Parser->{Debug} );  # DEBUG
    my $CC       = $COMPILER->new( Debug   => $Parser->{Debug},                    # Get new Compiler object
                                   Symbols => $PP->symbols() );
    my $Document = $CC->compile( Whitespace => $whitespace,                        # Compile Document Parser Model hierarchy
                                 Indent     => 0 );
    if( defined $Document ) {                                                      # Check for successful compilation
      print( STDERR "\tCompilation Complete\n" ) if( $Parser->{Debug} );
      $Parser->{Flags}->{Compiled} = 1;                                            # Flag Parser as compiled
      $Parser->{Flags}->{Ready   } = 1;                                            # Flag XML as ready for traversal
    } else {
      $Parser->{Flags}->{Error}   = 1;                                             # Raise error flag
      $Parser->{Errors}->{Count} += $CC->count();                                  # Increment error count
      push( @{$Parser->{Errors}->{Messages}}, $CC->errors() );                     # Import Compiler error messages
      push( @{$Parser->{Errors}->{Types}},    $CC->types() );                      # Import Compiler error types
      push( @{$Parser->{Errors}->{Samples}},  $CC->samples() );                    # Import Compiler error samples
      return( undef );                                                             # Return on error
    }
    $Parser->{Document} = $Document;                                               # Store Document in Parser object
  } else {
    $Parser->{Flags}->{Error}   = 1;                                               # Raise error flag
    $Parser->{Errors}->{Count} += $PP->count();                                    # Increment error count
    push( @{$Parser->{Errors}->{Messages}}, $PP->errors() );                       # Import Preprocessor error messages
    push( @{$Parser->{Errors}->{Types}},    $PP->types() );                        # Import Preprocessor error types
    push( @{$Parser->{Errors}->{Samples}},  $PP->samples() );                      # Import Preprocessor error samples
    return( undef );                                                               # Return on error
  }
  print( STDERR "XML Parsing Complete\n" ) if( $Parser->{Debug} );                 # DEBUG
  return( $Parser->{Document} );                                                   # Return compiled DOM object
}


sub flag {
  # This method returns a specified flag value.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash    {
  #              Flag => $flag
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Parser = shift;                   # Get Parser
  my %args   = @_;                      # Get arguments
  my $flag   = $args{Flag};             # Get required flag
  return( $Parser->{Flags}->{$flag} );  # Return the flag value
}


sub DESTROY {
  # This method is the object destructor for this class.
  my $Parser          = shift;
  $Parser->{XML}      = undef;
  $Parser->{Document} = undef;
  $Parser->{Errors}   = undef;
  undef %{$Parser};
  return(1);
}
