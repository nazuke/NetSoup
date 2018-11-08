#!/usr/local/bin/perl
#
#   NetSoup::HTML::Parser::Simple.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides a shortcut to parsing
#                reasonably error free HTML files using the NetSoup
#                XML Parser.
#
#   Methods:
#       parse  -  This method parses a chunk of HTML text into a DOM2 parse tree


package NetSoup::HTML::Parser::Simple;
use strict;
use NetSoup::XML::Parser;
use NetSoup::HTML::Parser::Simple::Document;
@NetSoup::HTML::Parser::Simple::ISA = qw( NetSoup::XML::Parser );
my $MODULE       = "Parser";
my $PREPROCESSOR = "NetSoup::XML::Parser::Preprocessor";
my $DOCUMENT     = "NetSoup::HTML::Parser::Simple::Document";
my $EMPTY        = [];
while( <NetSoup::HTML::Parser::Simple::DATA> ) {
  chomp;
  push( @{$EMPTY}, $_, uc($_) );
}
1;


sub parse {
  # This method parses a chunk of XML text into a list of Symbol objects.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash {
  #           XML => \$XML
  #         }
  # Result Returned:
  #    $Document || undef
  # Example:
  #    method call
  my $Parser = shift;                                                       # Get Parser
  my %args   = @_;                                                          # Get arguments
  my $XML    = $args{XML};                                                  # Get XML data reference
  $Parser->clearErr();                                                      # Clear accumulated error messages
  my $PP = $PREPROCESSOR->new( Debug         => $Parser->{Debug},           # Get new Preprocessor object
                               Strict        => $Parser->{Strict},
                               CaseSensitive => "no",
                               HTMLMode      => "yes",
                               ParseText     => "no",
                               Orphans       => 1,
                               Entities      => $Parser->{Entities},
                               Empty         => $EMPTY );
  my $preprocessed = $PP->preprocessor( XML        => $XML,                 # Preprocess XML into Symbol table
                                        Whitespace => "compact" );
  if( ( defined $preprocessed ) && ( $preprocessed == 1 ) ) {
    $Parser->{Flags}->{Preprocessed} = 1;                                    # Flag Parser as preprocessed
    $Parser->{Document} = $DOCUMENT->new( Symbols => $PP->symbols() );
  } else {
    $Parser->{Flags}->{Error}   = 1;                                        # Raise error flag
    $Parser->{Errors}->{Count} += $PP->count();                             # Increment error count
    push( @{$Parser->{Errors}->{Messages}}, $PP->errors() );                # Import Preprocessor error messages
    push( @{$Parser->{Errors}->{Types}},    $PP->types() );                 # Import Preprocessor error types
    push( @{$Parser->{Errors}->{Samples}},  $PP->samples() );               # Import Preprocessor error samples
    return( undef );                                                        # Return on error
  }
  return( $Parser->{Document} );                                            # Return compiled DOM object
}


__DATA__
area
base
basefont
bgsound
br
col
frame
hr
img
input
isindex
link
meta
nobr
param
spacer
wbr
