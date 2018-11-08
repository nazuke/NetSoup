#!/usr/local/bin/perl
#
#   NetSoup::XHTML::Util::CountWords.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides object methods for counting words.
#
#
#   Methods:
#       countxhtml  -  This method counts the words in a chunk of XHTML format text


package NetSoup::XHTML::Util::CountWords;
use strict;
use NetSoup::Text::CountWords;
use NetSoup::HTML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
@NetSoup::XHTML::Util::CountWords::ISA = qw( NetSoup::Text::CountWords );
my $PARSER       = "NetSoup::HTML::Parser";
my $TRAVERSAL    = "NetSoup::XML::DOM2::Traversal::DocumentTraversal";
1;


sub countxhtml {
  # This method counts the words in a chunk of XML format text.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              XHTML => \$XHTML
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    $count = $CountWords->countxhtml( XHTML => \$XHTML );
  my $CountWords = shift;                                                                  # Get object
  my %args       = @_;                                                                     # Get arguments
  my $debug      = $args{Debug} || 0;
  my $XHTML      = $args{XHTML};
  my $count      = 0;
  my $Parser     = $PARSER->new( Debug => $debug );
   my $Document   = $Parser->parse( XML => $XHTML );
  if( defined $Document ) {
    my $Traverser  = $TRAVERSAL->new();
    my $TreeWalker = $Traverser->createTreeWalker( Root                     => $Document,  #
                                                   WhatToShow               => undef,
                                                   Filter                   => undef,
                                                   EntityReferenceExpansion => 0 );
    my $callback   = sub {                                                                 # Create callback for Node processing
      my $Node = shift;                                                                    # Get Node to examine
    SWITCH: for( $Node->nodeType() ) {                                                     # Determine NodeType
        m/TEXT_NODE/i && do {                                                              # Check for scripting element
          my $Parent = $Node->parentNode();                                                # Get the Parent of this Node
          last SWITCH if( $Parent->nodeName() =~ m/^(script|style)$/i );                   # Ignore scripting elements
          # Fall Through...
        };
        m/(TEXT_NODE|CDATA_SECTION_NODE)/i && do {                                         # Handle regular text
          my $text = $Node->nodeValue() || $Node->data();                                  # Get Node text content
          $count  += $CountWords->count( Text => \$text );
          last SWITCH;
        };
        m/ELEMENT_NODE/i && do {                                                           # Handle known element attributes
          my $string = $Node->nodeValue();
          # Synchronise with NetSoup::XHTML::HyperGlot::Extract
          last SWITCH;
        };
      }
      return(1);
    };
    $TreeWalker->walkTree( Node     => $Document,                                          # Walk the Document tree
                           Callback => $callback );
  } else {
    foreach my $error ( $Parser->errors() ) {
      print( "$error\n" );
    }
    return( undef );
  }
  return( $count );
}
