#!/usr/local/bin/perl
#
#   NetSoup::XML::Util::CountWords.pm v00.00.01g 12042000
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
#       countxml  -  This method counts the words in a chunk of XML format text


package NetSoup::XML::Util::CountWords;
use strict;
use NetSoup::Text::CountWords;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
@NetSoup::XML::Util::CountWords::ISA = qw( NetSoup::Text::CountWords );
my $PARSER    = "NetSoup::XML::Parser";
my $TRAVERSAL = "NetSoup::XML::DOM2::Traversal::DocumentTraversal";
1;


sub countxml {
  # This method counts the words in a chunk of XML format text.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              XML => \$XML
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    $count = $CountWords->countxml( Text => \$Text );
  my $CountWords = shift;                                                                  # Get object
  my %args       = @_;                                                                     # Get arguments
  my $debug      = $args{Debug} || 0;
  my $XML        = $args{XML};
  my $count      = 0;
  my $Parser     = $PARSER->new( Debug => $debug,
                                 XML   => $XML );
  my $Document   = $Parser->parse();
  if( defined $Document ) {
    my $Traverser  = $TRAVERSAL->new();
    my $TreeWalker = $Traverser->createTreeWalker( Root                     => $Document,  #
                                                   WhatToShow               => undef,
                                                   Filter                   => undef,
                                                   EntityReferenceExpansion => 0 );
    my $callback   = sub {                                                                 # Create callback for Node processing
      my $Node = shift;                                                                    # Get Node to examine
    SWITCH: for( $Node->nodeType() ) {                                                     # Determine NodeType
        m/(TEXT_NODE|CDATA_SECTION_NODE)/i && do {                                         # Handle regular text
          my $text = $Node->nodeValue() || $Node->data();                                  # Get Node text content
          $count  += $CountWords->count( Text => \$text );
          last SWITCH;
        };
      }
      return(1);
    };
    $TreeWalker->walkTree( Node     => $Document,                                          # Walk the Document tree
                           Callback => $callback );
  } else {
    return( undef );
  }
  return( $count );
}
