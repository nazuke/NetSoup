#!/usr/local/bin/perl
#
#   NetSoup::XHTML::HyperGlot::Extract.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class is a member of the HyperGlot class.
#                This class is resonsible for building a table of
#                localisable strings inside an XML document.
#
#
#   Methods:
#       extract  -  This method extracts and stores the editable strings from XML data


package NetSoup::XHTML::HyperGlot::Extract;
use strict;
use NetSoup::Parse::Url;
use NetSoup::Protocol::GTP::Client;
use NetSoup::Protocol::HTTP_1;
use NetSoup::Text::CodePage::ascii2hex;
use NetSoup::Text::Glossary;
use NetSoup::XHTML::HyperGlot::Report;
use NetSoup::XML::DOM2;
use NetSoup::XML::DOM2::Traversal::DocumentTraversal;
@NetSoup::XHTML::HyperGlot::Extract::ISA = qw( NetSoup::XHTML::HyperGlot::Report );
my $ASCII2HEX = NetSoup::Text::CodePage::ascii2hex->new();
my $TRAVERSAL = "NetSoup::XML::DOM2::Traversal::DocumentTraversal";
1;


sub extract {
  # This method extracts and stores the editable strings from XML data.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           XML        => \$xml
  #           [ Pathname => $pathname ]
  #                      or
  #           [ Url      => $url ]
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Extract  = shift;                                     # Get object
  my %args     = @_;                                        # Get arguments
  my $xml      = $args{XML};                                # Get reference to XML data
  my $pathname = $args{Pathname} || "";                     # Check for pathname argument
  my $url      = $args{Url}      || "";                     # Check for Url argument
  my $location = $pathname       || $url || undef;          # Get document location
  $Extract->_load( %args );                                 # Load any required data
  $Extract->_populate( XML => $xml );                       # Populate Pairs hash
  if( $Extract->getConfig( Key => "GlotUseServ" ) ) {       # Use glossary database server...
    $Extract->debug( "Using Glossary Server..." );          # DEBUG
    my $lookup = NetSoup::Protocol::GTP::Client->new();     # Get new glossary object
    $lookup->lookup( SourceLang => $Extract->{SourceLang},  # Do glossary server lookup
                     TargetLang => $Extract->{TargetLang},
                     Strings    => $Extract->{Pairs},
                     Overwrite  => 0 );                     # No overwrite will return glossary suggestions
  } elsif( $Extract->getConfig( Key => "GlotDBPath" ) ) {   # ...or use local glossary database...
    $Extract->debug( "Using Local Glossary..." );           # DEBUG
    my $lookup = NetSoup::Text::Glossary->new();            # Get new glossary object
    $lookup->lookup( SourceLang => $Extract->{SourceLang},  # Do local glossary lookup
                     TargetLang => $Extract->{TargetLang},
                     Strings    => $Extract->{Pairs},
                     Overwrite  => 0 );                     # No overwrite will return glossary suggestions
  } else {                                                  # ...don't use any glossaries
    ;
  }
  return(1);
}


sub _load {
  # This private method determines whether any data needs
  # to be loaded from a pathname or a Url.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array      => \@array
  #              XML        => \$xml
  #              [ Pathname => $pathname ]
  #                         or
  #              [ Url      => $url ]
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Extract = shift;  # Get object
  my %args    = @_;     # Get arguments
  return(1);
}


sub _populate {
  # This private method populates the $Extract->{Pairs} hash.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              XML => \$XML
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Extract   = shift;                                                # Get object
  my %args      = @_;                                                   # Get arguments
  my $DOM2      = NetSoup::XML::DOM2->new();                            # Get new DOM2 object
  my $Document  = $DOM2->parse( XML => $args{XML} );                    # Parse XML data into DOM2 object
  my $Traversal = $TRAVERSAL->new();                                    # Prepare to traverse the DOM2
  my $Walker    = $Traversal->createTreeWalker( Root => $DOM2 );        # Traverse as a TreeWalker
  my $callback  = sub {                                                 # Callback populates the $Extract->{Pairs} hash
    my $Node = shift;                                                   # Get next XML Node
  SWITCH: for( $Node->nodeType() ) {
      m/(TEXT_NODE)/i && do {                                           # Check for scripting element
        my $Parent = $Node->parentNode();                               # Get the Parent of this Node
        last SWITCH if( $Parent->nodeName() =~ m/^(script|style)$/i );  # Ignore scripting elements
        # Fall Through...
      };
      m/(TEXT_NODE|CDATA_SECTION_NODE)/i && do {                        # Handle regular text
        my $string = $Node->nodeValue() || $Node->data();
        my $key    = "";                                                # Initialise hash key
        my $id     = $Extract->_id();                                   # Update unique ID counter
        $ASCII2HEX->ascii2hex( Data => \$string );                      # Hex-encode key to protect special characters
        $key                       = $string;
        $Extract->{IDField}->{$id} = $key;                              # Store ID of this key
        $Extract->{Pairs}->{$key}  = $string;                           # Store source/target string pair
        $Extract->{Hints}->{$key}  = $Extract->_hint( Node => $Node );  # Get descriptive hint
        last SWITCH;
      };
      m/ELEMENT_NODE/i && do {                                          # Handle known element attributes
        my $string = $Node->nodeValue();
        last SWITCH;
      };
    }
    return(1);
  };
  $Walker->walkTree( Node => $Document, Callback => $callback );        # Walk the Document tree
  return(1);
}


sub _hint {
  # This private method generates a descriptive hint for an element.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node => $Node
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Extract = shift;              # Get object
  my %args    = @_;                 # Get arguments
  my $Node    = $args{Node};        # Get Node object
  my $hint    = $Node->nodeName();  # Get the name of this Node
  return( $hint );
}


sub _id {
  # This method increments the unique ID counter.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $Extract    = shift;               # Get object
  $Extract->{ID} = $Extract->{ID} + 1;  # Increment ID counter
  return( $Extract->{ID} );
}
