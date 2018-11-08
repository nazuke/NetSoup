#!/usr/local/bin/perl
#
#   NetSoup::HTML::HTML2Text.pm v00.00.01g 12042000
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
#       html2text  -  This method converts HTML to plain text


package NetSoup::HTML::HTML2Text;
use strict;
use NetSoup::Core;
use NetSoup::HTML::Parser::Simple;
@NetSoup::HTML::HTML2Text::ISA = qw( NetSoup::Core );
1;


sub html2text {
  # This method converts HTML to plain text.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash {
  #           HTML => $HTML
  #           Wrap => 0 | 1
  #         }
  # Result Returned:
  #    $Text | undef
  # Example:
  #    method call
  my $HTML2Text = shift;                                        # Get HTML2Text
  my %args      = @_;                                           # Get arguments
  my $HTML      = $args{HTML};
  my $Wrap      = $args{Wrap} || 0;
  my $Text      = "";
  my $Parser    = NetSoup::HTML::Parser::Simple->new();
  my $Document  = $Parser->parse( XML => \$HTML );
  if( defined $Document ) {
    foreach my $Symbol ( $Document->symbols() ) {
    SWITCH: for( $Symbol->nodeType() ) {
        m/^TEXT_NODE$/i && do {
          if( $Wrap ) {
            $Text .= $HTML2Text->wrap( Text => $HTML2Text->clean( Text => $Symbol->nodeValue() ) );  #
          } else {
            $Text .= $HTML2Text->clean( Text => $Symbol->nodeValue() );  #
          }
          last SWITCH;
        };
        m/^br$/i && do {
          $Text .= "\n\n";
          last SWITCH;
        };
      }
    }
  } else {
    foreach my $error( $Parser->errors() ) {
      print( STDERR $error );
      $Text = undef;
    }
  }
  return( $Text );
}


sub clean {
  # This method cleans up the parsed text.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash {
  #           Text => $text
  #         }
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $HTML2Text = shift;
  my %args      = @_;                                           # Get arguments
  my $Text      = $args{Text};
  ( $Text )     = ( $Text =~ m/^[ \t\r\n]*(.+)[ \t\r\n]*$/s );
  $Text         =~ s/\&amp;/\&/gs;
  $Text         =~ s/\&nbsp;/ /gs;
  $Text         =~ s/\&lt;/</gs;
  $Text         =~ s/\&gt;/>/gs;
  $Text         =~ s/[ \t]+/ /gs;
  return( "$Text\n\n" );
}


sub wrap {
  # This method wraps a chunk of text to a width of 72 characters.
  # Calls:
  #    none
  # Parameters Required:
  #    Parser
  #    hash {
  #           Text => $text
  #         }
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $HTML2Text = shift;
  my %args      = @_;                         # Get arguments
  my $Text      = $args{Text};
  my @Tokens    = split( m/[ \t]+/, $Text );
  my $Wrapped   = "";
  my $count     = 0;
  my $max       = 72;
 CAT: foreach my $token ( @Tokens ) {
    if( $token =~ m/\n$/s ) {
      $count    = 0;
      $Wrapped .= $token;
    } else {
      $count += length( $token ) + 2;
      if( $count >= $max ) {
        $Wrapped .= "\n";
        $count    = 0;
        redo CAT;
      }
      $Wrapped .= $token . " ";
    }
  }
  return( $Wrapped );
}
